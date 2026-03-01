const express = require("express");
const cors = require("cors");
const { readDb, writeDb, resetDb } = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5174;

function nextId(items) {
  if (!items || items.length === 0) {
    return 1;
  }
  return Math.max(...items.map((item) => item.id)) + 1;
}

function getIngredientById(db, id) {
  return db.ingredients.find((ing) => ing.id === id);
}

function getDishIngredientIds(db, dish) {
  const ids = new Set(dish.ingredientIds || []);
  (dish.preparationIds || []).forEach((prepId) => {
    const prep = db.preparations.find((p) => p.id === prepId);
    if (!prep) {
      return;
    }
    (prep.ingredientItems || []).forEach((item) => {
      ids.add(item.ingredientId);
    });
  });
  return Array.from(ids);
}

function computeDishAllergens(db, dish) {
  const ingredientIds = getDishIngredientIds(db, dish);
  const allergens = new Set();
  const tracesAllergens = new Set();

  ingredientIds.forEach((id) => {
    const ing = getIngredientById(db, id);
    if (!ing) {
      return;
    }
    (ing.allergens || []).forEach((al) => allergens.add(al));
    (ing.tracesAllergens || []).forEach((al) => tracesAllergens.add(al));
  });

  return {
    ingredientIds,
    allergens: Array.from(allergens),
    tracesAllergens: Array.from(tracesAllergens)
  };
}

function decorateDish(db, dish) {
  const info = computeDishAllergens(db, dish);
  return {
    ...dish,
    ingredientIds: info.ingredientIds,
    allergens: info.allergens,
    tracesAllergens: info.tracesAllergens
  };
}

function validateDish(dish, restrictions) {
  const reasons = [];
  const restrictedAllergens = restrictions?.allergens || [];
  const restrictedTags = restrictions?.tags || [];

  const allergensHit = dish.allergens.filter((al) => restrictedAllergens.includes(al));
  if (allergensHit.length > 0) {
    reasons.push(`contiene ${allergensHit.join(", ")}`);
  }

  const tracesHit = dish.tracesAllergens.filter((al) => restrictedAllergens.includes(al));
  if (tracesHit.length > 0) {
    reasons.push(`trazas de ${tracesHit.join(", ")}`);
  }

  restrictedTags.forEach((tag) => {
    if (tag === "vegetariano" && dish.tags.includes("vegano")) {
      return;
    }
    if (!dish.tags.includes(tag)) {
      reasons.push(`no cumple ${tag}`);
    }
  });

  return {
    ok: reasons.length === 0,
    reasons
  };
}

app.get("/api/health", (req, res) => {
  res.json({ ok: true });
});

app.get("/api/config", (req, res) => {
  const db = readDb();
  res.json(db.config);
});

app.get("/api/context", (req, res) => {
  const db = readDb();
  res.json({
    events: db.events,
    restaurantGroups: db.restaurantGroups
  });
});

app.get("/api/ingredients", (req, res) => {
  const db = readDb();
  res.json(db.ingredients);
});

app.post("/api/ingredients", (req, res) => {
  const db = readDb();
  const newItem = {
    id: nextId(db.ingredients),
    ...req.body
  };
  db.ingredients.push(newItem);
  writeDb(db);
  res.json(newItem);
});

app.put("/api/ingredients/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  const idx = db.ingredients.findIndex((i) => i.id === id);
  if (idx === -1) {
    res.status(404).json({ error: "Not found" });
    return;
  }
  db.ingredients[idx] = { ...db.ingredients[idx], ...req.body, id };
  writeDb(db);
  res.json(db.ingredients[idx]);
});

app.delete("/api/ingredients/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  db.ingredients = db.ingredients.filter((i) => i.id !== id);
  writeDb(db);
  res.json({ ok: true });
});

app.get("/api/suppliers", (req, res) => {
  const db = readDb();
  res.json(db.suppliers);
});

app.post("/api/suppliers", (req, res) => {
  const db = readDb();
  const newItem = {
    id: nextId(db.suppliers),
    ...req.body
  };
  db.suppliers.push(newItem);
  writeDb(db);
  res.json(newItem);
});

app.put("/api/suppliers/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  const idx = db.suppliers.findIndex((i) => i.id === id);
  if (idx === -1) {
    res.status(404).json({ error: "Not found" });
    return;
  }
  db.suppliers[idx] = { ...db.suppliers[idx], ...req.body, id };
  writeDb(db);
  res.json(db.suppliers[idx]);
});

app.delete("/api/suppliers/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  db.suppliers = db.suppliers.filter((i) => i.id !== id);
  writeDb(db);
  res.json({ ok: true });
});

app.get("/api/preparations", (req, res) => {
  const db = readDb();
  res.json(db.preparations);
});

app.post("/api/preparations", (req, res) => {
  const db = readDb();
  const newItem = {
    id: nextId(db.preparations),
    ...req.body
  };
  db.preparations.push(newItem);
  writeDb(db);
  res.json(newItem);
});

app.put("/api/preparations/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  const idx = db.preparations.findIndex((i) => i.id === id);
  if (idx === -1) {
    res.status(404).json({ error: "Not found" });
    return;
  }
  db.preparations[idx] = { ...db.preparations[idx], ...req.body, id };
  writeDb(db);
  res.json(db.preparations[idx]);
});

app.delete("/api/preparations/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  db.preparations = db.preparations.filter((i) => i.id !== id);
  writeDb(db);
  res.json({ ok: true });
});

app.get("/api/dishes", (req, res) => {
  const db = readDb();
  const decorated = db.dishes.map((dish) => decorateDish(db, dish));
  res.json(decorated);
});

app.post("/api/dishes", (req, res) => {
  const db = readDb();
  const newItem = {
    id: nextId(db.dishes),
    ...req.body
  };
  db.dishes.push(newItem);
  writeDb(db);
  res.json(decorateDish(db, newItem));
});

app.put("/api/dishes/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  const idx = db.dishes.findIndex((i) => i.id === id);
  if (idx === -1) {
    res.status(404).json({ error: "Not found" });
    return;
  }
  db.dishes[idx] = { ...db.dishes[idx], ...req.body, id };
  writeDb(db);
  res.json(decorateDish(db, db.dishes[idx]));
});

app.delete("/api/dishes/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  db.dishes = db.dishes.filter((i) => i.id !== id);
  writeDb(db);
  res.json({ ok: true });
});

app.get("/api/menus", (req, res) => {
  const db = readDb();
  const { date, restaurantGroupId } = req.query;
  let menus = db.dailyMenus;
  if (date) {
    menus = menus.filter((m) => m.date === date);
  }
  if (restaurantGroupId) {
    menus = menus.filter((m) => String(m.restaurantGroupId) === String(restaurantGroupId));
  }
  const sorted = menus.slice().sort((a, b) => {
    if (b.revision !== a.revision) {
      return b.revision - a.revision;
    }
    return new Date(b.updatedAt) - new Date(a.updatedAt);
  });
  res.json({ menu: sorted[0] || null, revisions: sorted });
});

app.get("/api/menus/history", (req, res) => {
  const db = readDb();
  const { restaurantGroupId } = req.query;
  let menus = db.dailyMenus;
  if (restaurantGroupId) {
    menus = menus.filter((m) => String(m.restaurantGroupId) === String(restaurantGroupId));
  }
  menus = menus.slice().sort((a, b) => {
    if (a.date === b.date) {
      return b.revision - a.revision;
    }
    return new Date(b.date) - new Date(a.date);
  });
  res.json(menus);
});

app.post("/api/menus", (req, res) => {
  const db = readDb();
  const { date, restaurantGroupId, dishIds } = req.body;
  if (!date || !restaurantGroupId) {
    res.status(400).json({ error: "Missing fields" });
    return;
  }
  const current = db.dailyMenus.filter(
    (m) => m.date === date && Number(m.restaurantGroupId) === Number(restaurantGroupId)
  );
  const revision = current.length > 0 ? Math.max(...current.map((m) => m.revision)) + 1 : 1;
  const newMenu = {
    id: nextId(db.dailyMenus),
    date,
    restaurantGroupId: Number(restaurantGroupId),
    dishIds: dishIds || [],
    revision,
    updatedAt: new Date().toISOString()
  };
  db.dailyMenus.push(newMenu);
  writeDb(db);
  res.json(newMenu);
});

app.get("/api/tables", (req, res) => {
  const db = readDb();
  const { restaurantGroupId } = req.query;
  let tables = db.tables;
  if (restaurantGroupId) {
    tables = tables.filter((t) => String(t.restaurantGroupId) === String(restaurantGroupId));
  }
  res.json(tables);
});

app.patch("/api/tables/:id", (req, res) => {
  const db = readDb();
  const id = Number(req.params.id);
  const idx = db.tables.findIndex((t) => t.id === id);
  if (idx === -1) {
    res.status(404).json({ error: "Not found" });
    return;
  }
  db.tables[idx] = { ...db.tables[idx], ...req.body, id };
  writeDb(db);
  res.json(db.tables[idx]);
});

app.get("/api/orders", (req, res) => {
  const db = readDb();
  const { date, restaurantGroupId } = req.query;
  let orders = db.orders;
  if (date) {
    orders = orders.filter((o) => o.date === date);
  }
  if (restaurantGroupId) {
    orders = orders.filter((o) => String(o.restaurantGroupId) === String(restaurantGroupId));
  }
  res.json(orders);
});

app.post("/api/orders", (req, res) => {
  const db = readDb();
  const { tableId, date, restrictions, items } = req.body;
  const table = db.tables.find((t) => t.id === Number(tableId));
  if (!table) {
    res.status(400).json({ error: "Mesa invalida" });
    return;
  }
  const newOrder = {
    id: nextId(db.orders),
    tableId: Number(tableId),
    restaurantGroupId: table.restaurantGroupId,
    date,
    restrictions: restrictions || { allergens: [], tags: [], note: "" },
    items: (items || []).map((item, index) => ({
      id: index + 1,
      dishId: item.dishId,
      qty: item.qty || 1,
      note: item.note || "",
      status: "pendiente"
    })),
    status: "enviado",
    createdAt: new Date().toISOString()
  };
  db.orders.push(newOrder);
  const tableIdx = db.tables.findIndex((t) => t.id === table.id);
  if (tableIdx !== -1) {
    db.tables[tableIdx].status = "abierta";
  }
  writeDb(db);
  res.json(newOrder);
});

app.patch("/api/orders/:orderId/items/:itemId", (req, res) => {
  const db = readDb();
  const orderId = Number(req.params.orderId);
  const itemId = Number(req.params.itemId);
  const order = db.orders.find((o) => o.id === orderId);
  if (!order) {
    res.status(404).json({ error: "Order not found" });
    return;
  }
  const item = order.items.find((i) => i.id === itemId);
  if (!item) {
    res.status(404).json({ error: "Item not found" });
    return;
  }
  item.status = req.body.status || item.status;
  writeDb(db);
  res.json(item);
});

app.post("/api/admin/reset", (req, res) => {
  resetDb();
  res.json({ ok: true });
});

app.post("/api/validate", (req, res) => {
  const db = readDb();
  const { dishId, restrictions } = req.body;
  const dish = db.dishes.find((d) => d.id === Number(dishId));
  if (!dish) {
    res.status(404).json({ error: "Dish not found" });
    return;
  }
  const decorated = decorateDish(db, dish);
  res.json(validateDish(decorated, restrictions || {}));
});

app.listen(PORT, () => {
  console.log(`AllerFlow API en puerto ${PORT}`);
});
