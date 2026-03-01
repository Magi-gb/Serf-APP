import { useEffect, useMemo, useState } from "react";
import { api } from "./api.js";

const defaultRestrictions = { allergens: [], tags: [], note: "" };

function unique(arr) {
  return Array.from(new Set(arr));
}

function computeValidation(dish, restrictions) {
  const reasons = [];
  const allergensHit = dish.allergens.filter((al) => restrictions.allergens.includes(al));
  if (allergensHit.length > 0) {
    reasons.push(`contiene ${allergensHit.join(", ")}`);
  }
  const tracesHit = dish.tracesAllergens.filter((al) => restrictions.allergens.includes(al));
  if (tracesHit.length > 0) {
    reasons.push(`trazas de ${tracesHit.join(", ")}`);
  }
  restrictions.tags.forEach((tag) => {
    if (tag === "vegetariano" && dish.tags.includes("vegano")) {
      return;
    }
    if (!dish.tags.includes(tag)) {
      reasons.push(`no cumple ${tag}`);
    }
  });
  return { ok: reasons.length === 0, reasons };
}

function canAdapt(dish, restrictions) {
  if (!dish.isModifiable || dish.removableIngredientIds.length === 0) {
    return false;
  }
  const restrictedAllergens = restrictions.allergens;
  if (restrictedAllergens.length === 0 && restrictions.tags.length === 0) {
    return false;
  }
  const allergyBlocked = dish.allergens.some((al) => restrictedAllergens.includes(al));
  const tracesBlocked = dish.tracesAllergens.some((al) => restrictedAllergens.includes(al));
  const tagsBlocked = restrictions.tags.some((tag) => {
    if (tag === "vegetariano" && dish.tags.includes("vegano")) {
      return false;
    }
    return !dish.tags.includes(tag);
  });

  if (tagsBlocked) {
    return false;
  }

  return allergyBlocked || tracesBlocked;
}

function formatBadges(list) {
  if (!list || list.length === 0) {
    return "-";
  }
  return list.join(", ");
}

function App() {
  const [role, setRole] = useState("");
  const [eventId, setEventId] = useState("");
  const [groupId, setGroupId] = useState("");
  const [workDate, setWorkDate] = useState(new Date().toISOString().slice(0, 10));
  const [config, setConfig] = useState({ allergens: [], tags: [] });
  const [context, setContext] = useState({ events: [], restaurantGroups: [] });
  const [ingredients, setIngredients] = useState([]);
  const [suppliers, setSuppliers] = useState([]);
  const [preparations, setPreparations] = useState([]);
  const [dishes, setDishes] = useState([]);
  const [tables, setTables] = useState([]);
  const [menu, setMenu] = useState(null);
  const [menuRevisions, setMenuRevisions] = useState([]);
  const [adminMenu, setAdminMenu] = useState(null);
  const [adminMenuRevisions, setAdminMenuRevisions] = useState([]);
  const [menuHistory, setMenuHistory] = useState([]);
  const [orders, setOrders] = useState([]);
  const [view, setView] = useState("");
  const [selectedTableId, setSelectedTableId] = useState("");
  const [restrictions, setRestrictions] = useState(defaultRestrictions);
  const [orderItems, setOrderItems] = useState([]);
  const [alternatives, setAlternatives] = useState([]);
  const [adminDate, setAdminDate] = useState(workDate);
  const [duplicateFromDate, setDuplicateFromDate] = useState("");

  const group = useMemo(
    () => context.restaurantGroups.find((g) => String(g.id) === String(groupId)),
    [context, groupId]
  );

  useEffect(() => {
    Promise.all([api.getConfig(), api.getContext()])
      .then(([cfg, ctx]) => {
        setConfig(cfg);
        setContext(ctx);
        if (!eventId && ctx.events.length > 0) {
          setEventId(String(ctx.events[0].id));
        }
        if (!groupId && ctx.restaurantGroups.length > 0) {
          setGroupId(String(ctx.restaurantGroups[0].id));
        }
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    if (!groupId) {
      return;
    }
    Promise.all([
      api.getIngredients(),
      api.getSuppliers(),
      api.getPreparations(),
      api.getDishes(),
      api.getTables(groupId),
      api.getMenus(workDate, groupId),
      api.getMenusHistory(groupId),
      api.getOrders(workDate, groupId)
    ])
      .then(
        ([ingredientsData, suppliersData, prepData, dishData, tablesData, menuData, historyData, ordersData]) => {
          setIngredients(ingredientsData);
          setSuppliers(suppliersData);
          setPreparations(prepData);
          setDishes(dishData);
          setTables(tablesData);
          setMenu(menuData.menu);
          setMenuRevisions(menuData.revisions || []);
          setMenuHistory(historyData);
          setOrders(ordersData);
        }
      )
      .catch(() => {});
  }, [groupId, workDate]);

  useEffect(() => {
    if (!groupId) {
      return;
    }
    api
      .getMenus(adminDate, groupId)
      .then((menuData) => {
        setAdminMenu(menuData.menu);
        setAdminMenuRevisions(menuData.revisions || []);
      })
      .catch(() => {});
  }, [groupId, adminDate]);

  const menuDishes = useMemo(() => {
    if (!menu) {
      return [];
    }
    return menu.dishIds
      .map((id) => dishes.find((dish) => dish.id === id))
      .filter(Boolean);
  }, [menu, dishes]);

  const tablesById = useMemo(() => {
    const map = new Map();
    tables.forEach((table) => map.set(table.id, table));
    return map;
  }, [tables]);

  const handleEnter = () => {
    const initialView = role === "gestor" ? "Calendario" : role === "cocina" ? "Cola" : "Mesas";
    setView(initialView);
  };

  const updateTableStatus = (tableId, status) => {
    api.updateTable(tableId, { status }).then((updated) => {
      setTables((prev) => prev.map((t) => (t.id === updated.id ? updated : t)));
    });
  };

  const addDishToOrder = (dishId) => {
    setOrderItems((prev) => {
      const existing = prev.find((item) => item.dishId === dishId);
      if (existing) {
        return prev.map((item) => (item.dishId === dishId ? { ...item, qty: item.qty + 1 } : item));
      }
      return [...prev, { dishId, qty: 1, note: "" }];
    });
  };

  const handleOrderConfirm = () => {
    if (!selectedTableId || orderItems.length === 0) {
      return;
    }
    api
      .createOrder({
        tableId: Number(selectedTableId),
        date: workDate,
        restrictions,
        items: orderItems
      })
      .then((newOrder) => {
        setOrders((prev) => [...prev, newOrder]);
        setOrderItems([]);
        setAlternatives([]);
      });
  };

  const handleSuggest = () => {
    const allowed = menuDishes.filter((dish) => computeValidation(dish, restrictions).ok);
    if (allowed.length > 0) {
      setAlternatives(allowed);
      return;
    }
    const adaptable = menuDishes.filter((dish) => canAdapt(dish, restrictions));
    setAlternatives(adaptable);
  };

  const updateOrderItemStatus = (orderId, itemId, status) => {
    api.updateOrderItem(orderId, itemId, { status }).then((updated) => {
      setOrders((prev) =>
        prev.map((order) => {
          if (order.id !== orderId) {
            return order;
          }
          return {
            ...order,
            items: order.items.map((item) => (item.id === updated.id ? { ...item, status } : item))
          };
        })
      );
    });
  };

  const handleSaveMenu = (dishIds) => {
    api.saveMenu({ date: adminDate, restaurantGroupId: Number(groupId), dishIds }).then((saved) => {
      setAdminMenu(saved);
      setAdminMenuRevisions((prev) => [saved, ...prev]);
      if (adminDate === workDate) {
        setMenu(saved);
        setMenuRevisions((prev) => [saved, ...prev]);
      }
      setMenuHistory((prev) => [saved, ...prev]);
    });
  };

  const handleDuplicateMenu = () => {
    if (!duplicateFromDate) {
      return;
    }
    const source = menuHistory.find(
      (item) => item.date === duplicateFromDate && Number(item.restaurantGroupId) === Number(groupId)
    );
    if (!source) {
      return;
    }
    handleSaveMenu(source.dishIds);
  };

  if (!role) {
    return (
      <div className="page access">
        <header className="hero">
          <div>
            <h1>AllerFlow</h1>
            <p>Gestion diaria de menu, alergenos y flujo sala-cocina.</p>
          </div>
        </header>
        <section className="card">
          <h2>Acceso rapido</h2>
          <div className="form-grid">
            <label>
              Rol
              <select value={role} onChange={(event) => setRole(event.target.value)}>
                <option value="">Selecciona</option>
                <option value="sala">Camarero/a (Sala)</option>
                <option value="cocina">Cocina</option>
                <option value="gestor">Gestor/Administrador</option>
              </select>
            </label>
            <label>
              Evento
              <select value={eventId} onChange={(event) => setEventId(event.target.value)}>
                <option value="">Sin evento</option>
                {context.events.map((event) => (
                  <option key={event.id} value={event.id}>
                    {event.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Restaurante/Grupo
              <select value={groupId} onChange={(event) => setGroupId(event.target.value)}>
                {context.restaurantGroups.map((group) => (
                  <option key={group.id} value={group.id}>
                    {group.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Fecha de trabajo
              <input type="date" value={workDate} onChange={(event) => setWorkDate(event.target.value)} />
            </label>
          </div>
          <button className="primary" onClick={handleEnter} disabled={!role || !groupId}>
            Entrar
          </button>
        </section>
      </div>
    );
  }

  const roleViews = {
    sala: ["Mesas", "Comanda", "Estado"],
    cocina: ["Cola"],
    gestor: ["Calendario", "Ingredientes", "Proveedores", "Elaboraciones", "Platos", "Menu del dia"]
  };

  return (
    <div className="page app">
      <aside className="sidebar">
        <div className="brand">
          <h1>AllerFlow</h1>
          <span>{group?.name || ""}</span>
        </div>
        <div className="context">
          <p>Fecha: {workDate}</p>
          <p>Rol: {role}</p>
        </div>
        <nav>
          {roleViews[role].map((item) => (
            <button key={item} className={view === item ? "active" : ""} onClick={() => setView(item)}>
              {item}
            </button>
          ))}
        </nav>
        <button className="ghost" onClick={() => setRole("")}>Volver</button>
      </aside>
      <main>
        <header className="toolbar">
          <div>
            <strong>{view}</strong>
            <p>{group?.name || ""}</p>
          </div>
          <div className="toolbar-actions">
            <label>
              Fecha
              <input type="date" value={workDate} onChange={(event) => setWorkDate(event.target.value)} />
            </label>
            <label>
              Grupo
              <select value={groupId} onChange={(event) => setGroupId(event.target.value)}>
                {context.restaurantGroups.map((groupOption) => (
                  <option key={groupOption.id} value={groupOption.id}>
                    {groupOption.name}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </header>

        {role === "sala" && view === "Mesas" && (
          <section className="card">
            <h2>Mesas</h2>
            <div className="grid-3">
              {tables.map((table) => (
                <div key={table.id} className={`table-card status-${table.status}`}>
                  <h3>{table.nameOrNumber}</h3>
                  <p>Estado: {table.status}</p>
                  <div className="row">
                    <button onClick={() => updateTableStatus(table.id, "abierta")}>Abrir</button>
                    <button onClick={() => updateTableStatus(table.id, "cerrada")}>Cerrar</button>
                    <button
                      className="primary"
                      onClick={() => {
                        setSelectedTableId(String(table.id));
                        setView("Comanda");
                      }}
                    >
                      Entrar
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}

        {role === "sala" && view === "Comanda" && (
          <section className="card">
            <h2>Comanda de mesa</h2>
            <div className="form-grid">
              <label>
                Mesa
                <select value={selectedTableId} onChange={(event) => setSelectedTableId(event.target.value)}>
                  <option value="">Selecciona mesa</option>
                  {tables.map((table) => (
                    <option key={table.id} value={table.id}>
                      {table.nameOrNumber}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                Nota cocina
                <input
                  type="text"
                  value={restrictions.note}
                  onChange={(event) => setRestrictions({ ...restrictions, note: event.target.value })}
                />
              </label>
            </div>
            <div className="split">
              <div>
                <h3>Restricciones</h3>
                <div className="pill-grid">
                  {config.allergens.map((al) => (
                    <label key={al} className="pill">
                      <input
                        type="checkbox"
                        checked={restrictions.allergens.includes(al)}
                        onChange={(event) => {
                          const next = event.target.checked
                            ? unique([...restrictions.allergens, al])
                            : restrictions.allergens.filter((item) => item !== al);
                          setRestrictions({ ...restrictions, allergens: next });
                        }}
                      />
                      {al}
                    </label>
                  ))}
                </div>
                <h3>Preferencias</h3>
                <div className="pill-grid">
                  {config.tags.map((tag) => (
                    <label key={tag} className="pill">
                      <input
                        type="checkbox"
                        checked={restrictions.tags.includes(tag)}
                        onChange={(event) => {
                          const next = event.target.checked
                            ? unique([...restrictions.tags, tag])
                            : restrictions.tags.filter((item) => item !== tag);
                          setRestrictions({ ...restrictions, tags: next });
                        }}
                      />
                      {tag}
                    </label>
                  ))}
                </div>
              </div>
              <div>
                <h3>Menu del dia</h3>
                {menuDishes.length === 0 && <p>No hay menu cargado.</p>}
                <div className="stack">
                  {menuDishes.map((dish) => {
                    const validation = computeValidation(dish, restrictions);
                    return (
                      <div key={dish.id} className={`dish-card ${validation.ok ? "ok" : "warn"}`}>
                        <div>
                          <strong>{dish.name}</strong>
                          <p>Alergenos: {formatBadges(dish.allergens)}</p>
                          <p>Tags: {formatBadges(dish.tags)}</p>
                          {!validation.ok && <p className="warning">No apto: {validation.reasons.join(" / ")}</p>}
                        </div>
                        <button onClick={() => addDishToOrder(dish.id)}>Agregar</button>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>

            <div className="card-inner">
              <h3>Comanda actual</h3>
              {orderItems.length === 0 && <p>Sin platos.</p>}
              {orderItems.map((item) => {
                const dish = dishes.find((d) => d.id === item.dishId);
                return (
                  <div key={item.dishId} className="row space">
                    <span>{dish?.name}</span>
                    <input
                      type="number"
                      min="1"
                      value={item.qty}
                      onChange={(event) => {
                        const qty = Number(event.target.value);
                        setOrderItems((prev) =>
                          prev.map((entry) => (entry.dishId === item.dishId ? { ...entry, qty } : entry))
                        );
                      }}
                    />
                  </div>
                );
              })}
              <div className="row">
                <button onClick={handleSuggest}>Sugerir alternativas</button>
                <button className="primary" onClick={handleOrderConfirm}>
                  Confirmar comanda
                </button>
              </div>
              {alternatives.length > 0 && (
                <div className="notice">
                  <p>{alternatives[0].isModifiable ? "Adaptaciones posibles" : "Platos aptos"}</p>
                  <ul>
                    {alternatives.map((dish) => (
                      <li key={dish.id}>{dish.name}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          </section>
        )}

        {role === "sala" && view === "Estado" && (
          <section className="card">
            <h2>Estado de platos</h2>
            {orders.length === 0 && <p>Sin comandas.</p>}
            {orders.map((order) => (
              <div key={order.id} className="card-inner">
                <h3>Mesa {tablesById.get(order.tableId)?.nameOrNumber}</h3>
                <ul>
                  {order.items.map((item) => {
                    const dish = dishes.find((d) => d.id === item.dishId);
                    return (
                      <li key={item.id}>
                        {dish?.name} - {item.status}
                      </li>
                    );
                  })}
                </ul>
              </div>
            ))}
          </section>
        )}

        {role === "cocina" && view === "Cola" && (
          <section className="card">
            <h2>Cola de cocina</h2>
            {orders.length === 0 && <p>Sin pedidos.</p>}
            {orders.map((order) => (
              <div key={order.id} className="card-inner">
                <h3>Mesa {tablesById.get(order.tableId)?.nameOrNumber}</h3>
                <p className="muted">Nota: {order.restrictions?.note || "-"}</p>
                <div className="stack">
                  {order.items.map((item) => {
                    const dish = dishes.find((d) => d.id === item.dishId);
                    return (
                      <div key={item.id} className="row space">
                        <div>
                          <strong>{dish?.name}</strong>
                          <p className="muted">Restricciones: {formatBadges(order.restrictions?.allergens)}</p>
                        </div>
                        <div className="row">
                          <button onClick={() => updateOrderItemStatus(order.id, item.id, "pendiente")}>
                            Pendiente
                          </button>
                          <button onClick={() => updateOrderItemStatus(order.id, item.id, "en preparacion")}>
                            En preparacion
                          </button>
                          <button className="primary" onClick={() => updateOrderItemStatus(order.id, item.id, "listo")}>
                            Listo
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </section>
        )}

        {role === "gestor" && view === "Calendario" && (
          <section className="card">
            <h2>Historico de menus</h2>
            {menuHistory.length === 0 && <p>Sin historial.</p>}
            <div className="stack">
              {menuHistory.map((item) => (
                <div key={`${item.date}-${item.revision}`} className="row space">
                  <span>{item.date}</span>
                  <span>Revision {item.revision}</span>
                  <span>{item.updatedAt?.slice(0, 16).replace("T", " ")}</span>
                </div>
              ))}
            </div>
          </section>
        )}

        {role === "gestor" && view === "Ingredientes" && (
          <AdminIngredients
            ingredients={ingredients}
            suppliers={suppliers}
            allergens={config.allergens}
            onCreate={api.createIngredient}
            onUpdate={api.updateIngredient}
            onDelete={api.deleteIngredient}
            onRefresh={() => api.getIngredients().then(setIngredients)}
          />
        )}

        {role === "gestor" && view === "Proveedores" && (
          <AdminSuppliers
            suppliers={suppliers}
            onCreate={api.createSupplier}
            onUpdate={api.updateSupplier}
            onDelete={api.deleteSupplier}
            onRefresh={() => api.getSuppliers().then(setSuppliers)}
          />
        )}

        {role === "gestor" && view === "Elaboraciones" && (
          <AdminPreparations
            preparations={preparations}
            ingredients={ingredients}
            onCreate={api.createPreparation}
            onUpdate={api.updatePreparation}
            onDelete={api.deletePreparation}
            onRefresh={() => api.getPreparations().then(setPreparations)}
          />
        )}

        {role === "gestor" && view === "Platos" && (
          <AdminDishes
            dishes={dishes}
            ingredients={ingredients}
            preparations={preparations}
            tags={config.tags}
            onCreate={api.createDish}
            onUpdate={api.updateDish}
            onDelete={api.deleteDish}
            onRefresh={() => api.getDishes().then(setDishes)}
          />
        )}

        {role === "gestor" && view === "Menu del dia" && (
          <AdminMenu
            dishes={dishes}
            menu={adminMenu}
            adminDate={adminDate}
            setAdminDate={setAdminDate}
            onSave={handleSaveMenu}
            menuRevisions={adminMenuRevisions}
            menuHistory={menuHistory}
            duplicateFromDate={duplicateFromDate}
            setDuplicateFromDate={setDuplicateFromDate}
            onDuplicate={handleDuplicateMenu}
          />
        )}
      </main>
    </div>
  );
}

function AdminIngredients({ ingredients, suppliers, allergens, onCreate, onUpdate, onDelete, onRefresh }) {
  const empty = {
    name: "",
    supplierId: suppliers[0]?.id || "",
    allergens: [],
    tracesAllergens: [],
    notes: "",
    tracesNote: ""
  };
  const [form, setForm] = useState(empty);
  const [editingId, setEditingId] = useState(null);

  const startEdit = (item) => {
    setEditingId(item.id);
    setForm({ ...item });
  };

  const reset = () => {
    setEditingId(null);
    setForm({ ...empty, supplierId: suppliers[0]?.id || "" });
  };

  const submit = () => {
    const payload = { ...form, supplierId: Number(form.supplierId) };
    const action = editingId ? onUpdate(editingId, payload) : onCreate(payload);
    action.then(() => {
      reset();
      onRefresh();
    });
  };

  const toggleArray = (key, value) => {
    const set = form[key].includes(value)
      ? form[key].filter((item) => item !== value)
      : [...form[key], value];
    setForm({ ...form, [key]: set });
  };

  return (
    <section className="card">
      <h2>Ingredientes</h2>
      <div className="grid-2">
        <div>
          <h3>{editingId ? "Editar" : "Nuevo"}</h3>
          <div className="form-grid">
            <label>
              Nombre
              <input value={form.name} onChange={(event) => setForm({ ...form, name: event.target.value })} />
            </label>
            <label>
              Proveedor
              <select
                value={form.supplierId}
                onChange={(event) => setForm({ ...form, supplierId: event.target.value })}
              >
                {suppliers.map((sup) => (
                  <option key={sup.id} value={sup.id}>
                    {sup.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Notas
              <input value={form.notes} onChange={(event) => setForm({ ...form, notes: event.target.value })} />
            </label>
          </div>
          <p>Alergenos</p>
          <div className="pill-grid">
            {allergens.map((al) => (
              <label key={al} className="pill">
                <input
                  type="checkbox"
                  checked={form.allergens.includes(al)}
                  onChange={() => toggleArray("allergens", al)}
                />
                {al}
              </label>
            ))}
          </div>
          <p>Trazas</p>
          <div className="pill-grid">
            {allergens.map((al) => (
              <label key={al} className="pill">
                <input
                  type="checkbox"
                  checked={form.tracesAllergens.includes(al)}
                  onChange={() => toggleArray("tracesAllergens", al)}
                />
                {al}
              </label>
            ))}
          </div>
          <div className="row">
            <button className="primary" onClick={submit}>
              {editingId ? "Guardar" : "Crear"}
            </button>
            {editingId && <button onClick={reset}>Cancelar</button>}
          </div>
        </div>
        <div>
          <h3>Listado</h3>
          <div className="stack">
            {ingredients.map((item) => (
              <div key={item.id} className="row space">
                <span>{item.name}</span>
                <div className="row">
                  <button onClick={() => startEdit(item)}>Editar</button>
                  <button onClick={() => onDelete(item.id).then(onRefresh)}>Eliminar</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function AdminSuppliers({ suppliers, onCreate, onUpdate, onDelete, onRefresh }) {
  const empty = { name: "", technicalSheetUrlOrText: "" };
  const [form, setForm] = useState(empty);
  const [editingId, setEditingId] = useState(null);

  const submit = () => {
    const action = editingId ? onUpdate(editingId, form) : onCreate(form);
    action.then(() => {
      setForm(empty);
      setEditingId(null);
      onRefresh();
    });
  };

  return (
    <section className="card">
      <h2>Proveedores</h2>
      <div className="grid-2">
        <div>
          <div className="form-grid">
            <label>
              Nombre
              <input value={form.name} onChange={(event) => setForm({ ...form, name: event.target.value })} />
            </label>
            <label>
              Ficha tecnica
              <input
                value={form.technicalSheetUrlOrText}
                onChange={(event) => setForm({ ...form, technicalSheetUrlOrText: event.target.value })}
              />
            </label>
          </div>
          <div className="row">
            <button className="primary" onClick={submit}>
              {editingId ? "Guardar" : "Crear"}
            </button>
            {editingId && (
              <button
                onClick={() => {
                  setForm(empty);
                  setEditingId(null);
                }}
              >
                Cancelar
              </button>
            )}
          </div>
        </div>
        <div>
          <h3>Listado</h3>
          <div className="stack">
            {suppliers.map((item) => (
              <div key={item.id} className="row space">
                <span>{item.name}</span>
                <div className="row">
                  <button
                    onClick={() => {
                      setEditingId(item.id);
                      setForm(item);
                    }}
                  >
                    Editar
                  </button>
                  <button onClick={() => onDelete(item.id).then(onRefresh)}>Eliminar</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function AdminPreparations({ preparations, ingredients, onCreate, onUpdate, onDelete, onRefresh }) {
  const empty = { name: "", ingredientItems: [] };
  const [form, setForm] = useState(empty);
  const [editingId, setEditingId] = useState(null);

  const toggleIngredient = (id) => {
    const exists = form.ingredientItems.find((item) => item.ingredientId === id);
    const next = exists
      ? form.ingredientItems.filter((item) => item.ingredientId !== id)
      : [...form.ingredientItems, { ingredientId: id }];
    setForm({ ...form, ingredientItems: next });
  };

  const submit = () => {
    const action = editingId ? onUpdate(editingId, form) : onCreate(form);
    action.then(() => {
      setForm(empty);
      setEditingId(null);
      onRefresh();
    });
  };

  return (
    <section className="card">
      <h2>Elaboraciones</h2>
      <div className="grid-2">
        <div>
          <div className="form-grid">
            <label>
              Nombre
              <input value={form.name} onChange={(event) => setForm({ ...form, name: event.target.value })} />
            </label>
          </div>
          <p>Ingredientes</p>
          <div className="pill-grid">
            {ingredients.map((item) => (
              <label key={item.id} className="pill">
                <input
                  type="checkbox"
                  checked={form.ingredientItems.some((entry) => entry.ingredientId === item.id)}
                  onChange={() => toggleIngredient(item.id)}
                />
                {item.name}
              </label>
            ))}
          </div>
          <div className="row">
            <button className="primary" onClick={submit}>
              {editingId ? "Guardar" : "Crear"}
            </button>
            {editingId && (
              <button
                onClick={() => {
                  setForm(empty);
                  setEditingId(null);
                }}
              >
                Cancelar
              </button>
            )}
          </div>
        </div>
        <div>
          <h3>Listado</h3>
          <div className="stack">
            {preparations.map((item) => (
              <div key={item.id} className="row space">
                <span>{item.name}</span>
                <div className="row">
                  <button
                    onClick={() => {
                      setEditingId(item.id);
                      setForm(item);
                    }}
                  >
                    Editar
                  </button>
                  <button onClick={() => onDelete(item.id).then(onRefresh)}>Eliminar</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function AdminDishes({ dishes, ingredients, preparations, tags, onCreate, onUpdate, onDelete, onRefresh }) {
  const empty = {
    name: "",
    preparationIds: [],
    ingredientIds: [],
    tags: [],
    removableIngredientIds: [],
    isModifiable: false
  };
  const [form, setForm] = useState(empty);
  const [editingId, setEditingId] = useState(null);

  const toggleArray = (key, value) => {
    const set = form[key].includes(value)
      ? form[key].filter((item) => item !== value)
      : [...form[key], value];
    setForm({ ...form, [key]: set });
  };

  const submit = () => {
    const payload = {
      ...form,
      preparationIds: form.preparationIds.map(Number),
      ingredientIds: form.ingredientIds.map(Number),
      removableIngredientIds: form.removableIngredientIds.map(Number)
    };
    const action = editingId ? onUpdate(editingId, payload) : onCreate(payload);
    action.then(() => {
      setForm(empty);
      setEditingId(null);
      onRefresh();
    });
  };

  return (
    <section className="card">
      <h2>Platos</h2>
      <div className="grid-2">
        <div>
          <div className="form-grid">
            <label>
              Nombre
              <input value={form.name} onChange={(event) => setForm({ ...form, name: event.target.value })} />
            </label>
            <label>
              Modificable
              <input
                type="checkbox"
                checked={form.isModifiable}
                onChange={(event) => setForm({ ...form, isModifiable: event.target.checked })}
              />
            </label>
          </div>
          <p>Elaboraciones</p>
          <div className="pill-grid">
            {preparations.map((item) => (
              <label key={item.id} className="pill">
                <input
                  type="checkbox"
                  checked={form.preparationIds.includes(item.id)}
                  onChange={() => toggleArray("preparationIds", item.id)}
                />
                {item.name}
              </label>
            ))}
          </div>
          <p>Ingredientes directos</p>
          <div className="pill-grid">
            {ingredients.map((item) => (
              <label key={item.id} className="pill">
                <input
                  type="checkbox"
                  checked={form.ingredientIds.includes(item.id)}
                  onChange={() => toggleArray("ingredientIds", item.id)}
                />
                {item.name}
              </label>
            ))}
          </div>
          <p>Tags</p>
          <div className="pill-grid">
            {tags.map((tag) => (
              <label key={tag} className="pill">
                <input
                  type="checkbox"
                  checked={form.tags.includes(tag)}
                  onChange={() => toggleArray("tags", tag)}
                />
                {tag}
              </label>
            ))}
          </div>
          <p>Ingredientes removibles</p>
          <div className="pill-grid">
            {ingredients.map((item) => (
              <label key={item.id} className="pill">
                <input
                  type="checkbox"
                  checked={form.removableIngredientIds.includes(item.id)}
                  onChange={() => toggleArray("removableIngredientIds", item.id)}
                />
                {item.name}
              </label>
            ))}
          </div>
          <div className="row">
            <button className="primary" onClick={submit}>
              {editingId ? "Guardar" : "Crear"}
            </button>
            {editingId && (
              <button
                onClick={() => {
                  setForm(empty);
                  setEditingId(null);
                }}
              >
                Cancelar
              </button>
            )}
          </div>
        </div>
        <div>
          <h3>Listado</h3>
          <div className="stack">
            {dishes.map((item) => (
              <div key={item.id} className="row space">
                <span>{item.name}</span>
                <div className="row">
                  <button
                    onClick={() => {
                      setEditingId(item.id);
                      setForm({
                        ...item,
                        preparationIds: item.preparationIds || [],
                        ingredientIds: item.ingredientIds || [],
                        removableIngredientIds: item.removableIngredientIds || []
                      });
                    }}
                  >
                    Editar
                  </button>
                  <button onClick={() => onDelete(item.id).then(onRefresh)}>Eliminar</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function AdminMenu({
  dishes,
  menu,
  adminDate,
  setAdminDate,
  onSave,
  menuRevisions,
  menuHistory,
  duplicateFromDate,
  setDuplicateFromDate,
  onDuplicate
}) {
  const [selectedDishIds, setSelectedDishIds] = useState(menu?.dishIds || []);

  useEffect(() => {
    setSelectedDishIds(menu?.dishIds || []);
  }, [menu]);

  const toggleDish = (id) => {
    setSelectedDishIds((prev) => (prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]));
  };

  return (
    <section className="card">
      <h2>Menu del dia</h2>
      <div className="form-grid">
        <label>
          Fecha
          <input type="date" value={adminDate} onChange={(event) => setAdminDate(event.target.value)} />
        </label>
      </div>
      <div className="pill-grid">
        {dishes.map((dish) => (
          <label key={dish.id} className="pill">
            <input type="checkbox" checked={selectedDishIds.includes(dish.id)} onChange={() => toggleDish(dish.id)} />
            {dish.name}
          </label>
        ))}
      </div>
      <div className="row">
        <button className="primary" onClick={() => onSave(selectedDishIds)}>
          Guardar menu
        </button>
      </div>
      <div className="card-inner">
        <h3>Duplicar desde fecha</h3>
        <div className="row">
          <select value={duplicateFromDate} onChange={(event) => setDuplicateFromDate(event.target.value)}>
            <option value="">Selecciona fecha</option>
            {unique(menuHistory.map((item) => item.date)).map((date) => (
              <option key={date} value={date}>
                {date}
              </option>
            ))}
          </select>
          <button onClick={onDuplicate}>Duplicar</button>
        </div>
      </div>
      <div className="card-inner">
        <h3>Revisiones</h3>
        {menuRevisions.map((item) => (
          <div key={`${item.date}-${item.revision}`} className="row space">
            <span>{item.date}</span>
            <span>Revision {item.revision}</span>
            <span>{item.updatedAt?.slice(0, 16).replace("T", " ")}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

export default App;
