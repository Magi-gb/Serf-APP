# CRUD82-84 — Revisión de código (Ingredients + Restriccions)

**Rama:** `feature/tasks#82-84`
**Base:** `develop`
**Fecha:** 2026-04-11

---

## BUG-1 — Tabla `restriccios` duplica la tabla `restrictions` ya existente (CRITICAL)

La rama `develop` ya contiene una tabla `restrictions` (con columnas `name`, `description`, `bg_color`, `icon_svg`), un modelo `Restriction`, un controlador `RestrictionsController` y rutas `resources :restrictions`. Esta rama crea una **segunda tabla paralela** llamada `restriccios` con su propio modelo `Restriccio`, controlador `RestriccionsController` y rutas `resources :restriccions`.

El mismo concepto de dominio existe dos veces con nombres diferentes. Se debe reutilizar la infraestructura existente de `Restriction` en `develop` y no duplicarla.

**Acción requerida:** Eliminar el modelo `Restriccio`, la migración `create_restriccios`, el controlador `RestriccionsController` y todas las vistas de `restriccions/`. Utilizar el modelo `Restriction` existente como base. La tabla join debe llamarse `ingredient_restrictions` (no `ingredient_restriccios`).

## BUG-2 — Nombres de modelos y tablas en catalán (CRITICAL)

El CLAUDE.md establece: *"All model names, column names, variable names, and code must be in English."*

Nombres que violan esta convención:
- `Restriccio` → debe ser `Restriction` (ya existe)
- `IngredientRestriccio` → debe ser `IngredientRestriction`
- Tabla `restriccios` → debe ser `restrictions` (ya existe)
- Tabla `ingredient_restriccios` → debe ser `ingredient_restrictions`

**Acción requerida:** Renombrar todo a inglés. Dado que `Restriction` ya existe en `develop`, solo hace falta crear `IngredientRestriction` como tabla join.

## BUG-3 — Literales sin internacionalización (CRITICAL)

Ambos controladores contienen mensajes flash con texto directo, sin usar I18n:

`IngredientsController`:
- `"Ingredient created successfully."`
- `"Ingredient updated successfully."`
- `"Ingredient deleted."`

`RestriccionsController`:
- `"Restricció creada correctament."`
- `"Restricció actualitzada correctament."`
- `"Restricció eliminada."`

El CLAUDE.md establece: *"No hardcoded text in views or flash messages."*

**Acción requerida:** Sustituir todos los literales por claves I18n definidas en `config/locales/ca.yml`.

## BUG-4 — Rutas basura del generador de scaffold (HIGH)

El archivo `config/routes.rb` contiene 8 rutas manuales GET innecesarias:

```ruby
get "restriccions/index"
get "restriccions/show"
get "restriccions/new"
get "restriccions/edit"
get "restriccion/index"
get "restriccion/show"
get "restriccion/new"
get "restriccion/edit"
```

Estas son redundantes ya que `resources :restriccions` define todas las rutas RESTful. Además mezclan singular (`restriccion`) y plural (`restriccions`).

**Acción requerida:** Eliminar las 8 rutas manuales.

## BUG-5 — Vistas son placeholders sin funcionalidad (HIGH)

Las 12 vistas creadas (tanto para `ingredients` como para `restriccions`) son stubs del generador:

```erb
<h1>Ingredients#create</h1>
<p>Find me in app/views/ingredients/create.html.erb</p>
```

No hay formularios, ni listados, ni páginas show reales. Además, existen vistas `create.html.erb` y `update.html.erb` que no deberían existir — esas acciones redirigen en éxito o re-renderizan `new`/`edit` en error.

**Acción requerida:** Implementar las vistas reales con formularios funcionales. Eliminar `create.html.erb` y `update.html.erb`.

## BUG-6 — Tests rotos y no funcionales (HIGH)

### Tests de controladores
- Usan URL helpers inexistentes: `ingredients_index_url`, `ingredients_show_url`, `ingredients_create_url`, etc. Con `resources :ingredients`, los helpers correctos son `ingredients_url`, `ingredient_url(id)`, `new_ingredient_url`, etc.
- Usan `get` para acciones `create` y `update`, que requieren `post` y `patch`/`put`.
- No incluyen autenticación — las peticiones serán redirigidas al login por Devise.

### Tests de modelos
- Los 3 ficheros de test de modelos (`ingredient_test.rb`, `restriccio_test.rb`, `ingredient_restriccio_test.rb`) están vacíos — solo contienen código comentado.

**Acción requerida:** Reescribir los tests de controlador con los URL helpers correctos, verbos HTTP correctos y autenticación. Implementar tests de modelo para validaciones y asociaciones.

## BUG-7 — Sin validaciones en el modelo Ingredient (MEDIUM)

`Restriccio` tiene `validates :name, presence: true, uniqueness: true` y `validates :description, presence: true`, pero `Ingredient` no tiene **ninguna validación**. Como mínimo, `name` debería ser obligatorio y único.

**Acción requerida:** Añadir validaciones a `Ingredient` (`name`: presence + uniqueness como mínimo).

## BUG-8 — Falta `dependent: :destroy` en asociaciones (MEDIUM)

Ni `Ingredient` ni `Restriccio` declaran `dependent: :destroy` en sus `has_many :ingredient_restriccios`. Eliminar un ingrediente o restricción dejará registros huérfanos en la tabla join (o lanzará errores de clave foránea).

**Acción requerida:** Añadir `dependent: :destroy` a las asociaciones `has_many :ingredient_restriccios` de ambos modelos.

## BUG-9 — Sin control de acceso (MEDIUM)

La aplicación ya tiene el concern `Authorizable` con guards `require_admin!` y `require_kitchen_manager_or_above!`. Ninguno de los dos controladores nuevos aplica control de acceso — cualquier usuario autenticado (incluidos camareros) puede crear, editar y eliminar ingredientes y restricciones.

**Acción requerida:** Aplicar `before_action :require_kitchen_manager_or_above!` (o el guard apropiado) a las acciones de escritura.

## BUG-10 — Fixtures con nombres duplicados (MEDIUM)

Tanto `ingredients.yml` como `restriccios.yml` tienen `name: MyString` para los fixtures `:one` y `:two`. Dado que `Restriccio` valida `uniqueness: true` en `name`, la carga de fixtures fallará en los tests.

**Acción requerida:** Asignar nombres únicos y descriptivos a cada fixture.

## BUG-11 — Falta `null: false` en `ingredients.name` a nivel de BD (LOW)

La migración `create_ingredients` permite `NULL` en la columna `name`. Si se va a validar presencia a nivel de modelo, también debería reforzarse a nivel de base de datos.

**Acción requerida:** Añadir `null: false` a `t.string :name` en la migración de ingredients.

## BUG-12 — No se han añadido seeds (LOW)

El CLAUDE.md requiere fixtures **y** seeds para cada feature. No se ha modificado `db/seeds.rb`.

**Acción requerida:** Añadir seeds de ejemplo para ingredients en `db/seeds.rb`.

---

## Resumen

Esta rama introduce CRUDs para Ingredient y Restriction (como "Restriccio"), pero **conflicta con la infraestructura de `restrictions` ya existente en `develop`**, viola múltiples convenciones del proyecto (nombres en inglés, I18n, sin literales en código), tiene tests completamente no funcionales, vistas placeholder y carece de control de acceso.

**Recomendación:** Rechazar y rehacer. Usar el modelo/tabla/controlador `Restriction` existente en `develop` como base. Añadir solo el modelo `Ingredient`, la tabla join `IngredientRestriction` (en inglés) y el `IngredientsController`, con vistas funcionales, tests reales, I18n, validaciones y autorización.
