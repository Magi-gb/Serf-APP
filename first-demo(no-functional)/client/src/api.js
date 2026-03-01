async function request(path, options = {}) {
  const res = await fetch(path, {
    headers: { "Content-Type": "application/json" },
    ...options
  });
  if (!res.ok) {
    const error = await res.json().catch(() => ({}));
    throw new Error(error.error || "Error de red");
  }
  return res.json();
}

export const api = {
  getConfig: () => request("/api/config"),
  getContext: () => request("/api/context"),
  getIngredients: () => request("/api/ingredients"),
  createIngredient: (data) => request("/api/ingredients", { method: "POST", body: JSON.stringify(data) }),
  updateIngredient: (id, data) =>
    request(`/api/ingredients/${id}`, { method: "PUT", body: JSON.stringify(data) }),
  deleteIngredient: (id) => request(`/api/ingredients/${id}`, { method: "DELETE" }),
  getSuppliers: () => request("/api/suppliers"),
  createSupplier: (data) => request("/api/suppliers", { method: "POST", body: JSON.stringify(data) }),
  updateSupplier: (id, data) => request(`/api/suppliers/${id}`, { method: "PUT", body: JSON.stringify(data) }),
  deleteSupplier: (id) => request(`/api/suppliers/${id}`, { method: "DELETE" }),
  getPreparations: () => request("/api/preparations"),
  createPreparation: (data) => request("/api/preparations", { method: "POST", body: JSON.stringify(data) }),
  updatePreparation: (id, data) =>
    request(`/api/preparations/${id}`, { method: "PUT", body: JSON.stringify(data) }),
  deletePreparation: (id) => request(`/api/preparations/${id}`, { method: "DELETE" }),
  getDishes: () => request("/api/dishes"),
  createDish: (data) => request("/api/dishes", { method: "POST", body: JSON.stringify(data) }),
  updateDish: (id, data) => request(`/api/dishes/${id}`, { method: "PUT", body: JSON.stringify(data) }),
  deleteDish: (id) => request(`/api/dishes/${id}`, { method: "DELETE" }),
  getMenus: (date, restaurantGroupId) =>
    request(`/api/menus?date=${date}&restaurantGroupId=${restaurantGroupId}`),
  getMenusHistory: (restaurantGroupId) =>
    request(`/api/menus/history?restaurantGroupId=${restaurantGroupId}`),
  saveMenu: (data) => request("/api/menus", { method: "POST", body: JSON.stringify(data) }),
  getTables: (restaurantGroupId) => request(`/api/tables?restaurantGroupId=${restaurantGroupId}`),
  updateTable: (id, data) => request(`/api/tables/${id}`, { method: "PATCH", body: JSON.stringify(data) }),
  getOrders: (date, restaurantGroupId) =>
    request(`/api/orders?date=${date}&restaurantGroupId=${restaurantGroupId}`),
  createOrder: (data) => request("/api/orders", { method: "POST", body: JSON.stringify(data) }),
  updateOrderItem: (orderId, itemId, data) =>
    request(`/api/orders/${orderId}/items/${itemId}`, { method: "PATCH", body: JSON.stringify(data) })
};
