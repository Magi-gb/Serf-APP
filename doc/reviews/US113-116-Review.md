# US113-116 — Revisión de código (Ingredients CRUD completo)

**Rama:** `US113-114-115-116-Ingredients-CRUD`
**Base:** `develop` (después de merge)
**Fecha:** 2026-04-11

---

## Problemas encontrados y corregidos

### BUG-1 — Vistas vacías innecesarias (HIGH) — CORREGIDO

Se habían creado `create.html.erb`, `update.html.erb` y `destroy.html.erb` vacíos. Estas acciones redirigen o re-renderizan, nunca renderizan su propia plantilla. Eliminados.

### BUG-2 — Offenses de RuboCop (HIGH) — CORREGIDO

3 offenses detectadas (espacios en arrays, trailing empty lines). Corregidas con `bin/rubocop -A`.

### BUG-3 — Comentario en castellano en `HomeController` (LOW) — CORREGIDO

`# El usuario actual está disponible como current_user` — comentario innecesario en castellano. Eliminado.

### BUG-4 — Validación `password_confirmation` del modelo User (MEDIUM) — VERIFICADO

La validación ya estaba presente en develop. No había regresión real.

### BUG-5 — Ruta y vista `ingredients-delete` no RESTful (MEDIUM) — CORREGIDO

Existía una ruta custom `GET /ingredients-delete` con una acción `delete` y vista dedicada para eliminar ingredients desde una tabla separada. Esto duplicaba funcionalidad y no seguía las convenciones REST.

- Eliminada la ruta `get "ingredients-delete"`
- Eliminada la acción `delete` del controlador
- Eliminada la vista `delete.html.erb`
- Corregido el botón de eliminación en `show.html.erb`: usaba `link_to ... method: :delete` (rails-ujs, no funciona con Turbo). Cambiado a `button_to ... method: :delete` con `turbo_confirm` (patrón correcto de Turbo, consistente con `restrictions/show.html.erb`)
- Eliminada la ruta duplicada `resources :ingredients` (existían dos declaraciones)

### BUG-6 — Inline styles en vistas de usuarios (LOW) — DESCARTADO

Las vistas usan `style="--avatar-bg: ..."` que es una variable CSS, no un estilo inline directo. El estilo real está en la clase CSS. Es el patrón aceptado para colores dinámicos (mismo enfoque que `--bg-color` en las vistas de restricciones).

### BUG-7 — Fixtures de `ingredient_restrictions` vaciados (LOW) — CORREGIDO

El fixture estaba vacío. Añadido fixture `bread_gluten` que asocia el ingredient `bread` con la restriction `gluten`.

### BUG-8 — Tests de `dependent: :destroy` eliminados (LOW) — CORREGIDO

Restaurados tests que verifican que eliminar un `Ingredient` o `Restriction` destruye los `IngredientRestriction` asociados.

### BUG-9 — Documentación generada por IA excesiva (LOW) — CORREGIDO

Eliminados 5 ficheros de documentación generada (973 líneas) que no aportaban valor: `CHANGES_SUMMARY.md`, `IMPLEMENTATION_COMPLETE.md`, `QUICKSTART.md`, `doc/INGREDIENTS_ACCESS_GUIDE.md`, `doc/ingredients_feature.md`.

### BUG-10 — Seeds sin `bg_color` ni `description` para restricciones (LOW) — CORREGIDO

Los seeds de restricciones no incluían `bg_color`, `description` ni `icon_svg`. Las vistas de restricciones los utilizan. Añadidos `bg_color` y `description` a todos los seeds de restricciones (14 al·lèrgens EU + 6 religioses).

### BUG-11 — Inconsistències d'estil entre vistes (LOW) — PENDENT

Les vistes d'ingredients utilitzen classes BEM noves (`ingredients-header`, `ingredients-table`, `btn btn--primary`, etc.) amb CSS a `ingredients.css`. Les vistes existents (users, restrictions, profiles) utilitzen les classes originals de `style_definition.css` (`page-card`, `btn-primary`, `sidenav`, etc.). Això crea dues convencions CSS coexistint al projecte.

La sidebar es va restaurar a la versió de develop (classes `sidenav`) per mantenir l'estil consistent amb la resta de l'aplicació.

**Acció recomanada:** En un futur sprint, unificar les convencions CSS de tot el projecte.

---

## Estado actual

- **Tests:** 93 tests, 187 assertions, 0 failures, 0 errors
- **I18n:** 0 claves faltantes
- **RuboCop:** 0 offenses
- **Brakeman:** 0 warnings
- **Esquema:** `ingredients` (name, description), `restrictions` (name, restriction_type, description, bg_color, icon_svg), `ingredient_restrictions` (join)
- **UI:** Funcional. Sidebar amb classes `sidenav` de develop. Vistes d'ingredients amb classes BEM + `ingredients.css`. Dashboard amb `dashboard.css`.

## Resumen

La rama implementa el CRUD completo de ingredients con vistas funcionales (index con tabla y búsqueda, show con restricciones, new/edit con checkboxes de restricciones por tipo), dashboard con secciones por rol, sidebar con enlace a ingredients, y seeds con 14 al·lèrgens EU + 6 restricciones religiosas + 12 ingredients de ejemplo.

Todos los problemas bloqueantes y funcionales han sido corregidos. Queda pendiente la unificación de convenciones CSS (BUG-11).
