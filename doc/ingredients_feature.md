# Ingredients Management Feature - Documentación

## Overview
Se ha implementado un sistema completo de gestión de ingredientes con restricciones alimentarias para el usuario "cuiner" (kitchen_manager) del sistema Serf.

## Componentes Implementados

### 1. Modelos (Domain Models)

#### Restriction
- **Tabla:** restrictions
- **Campos:**
  - `name` (string, NOT NULL, UNIQUE): Nombre de la restricción
  - `restriction_type` (integer, NOT NULL): Tipo de restricción (enum)
  - `description` (text): Descripción de la restricción
- **Enum restriction_type:**
  - `intolerance_allergy` (0): Intolerancias y alergias (14 de la UE)
  - `religious` (1): Restricciones religiosas
- **Asociaciones:**
  - `has_many :ingredient_restrictions`
  - `has_many :ingredients, through: :ingredient_restrictions`
- **Validaciones:**
  - Presencia de name
  - Unicidad de name
  - Presencia de restriction_type

#### Ingredient
- **Tabla:** ingredients
- **Campos:**
  - `name` (string, NOT NULL, UNIQUE): Nombre del ingrediente
  - `description` (text): Descripción del ingrediente
- **Asociaciones:**
  - `has_many :ingredient_restrictions`
  - `has_many :restrictions, through: :ingredient_restrictions`
- **Scopes:**
  - `search(query)`: Búsqueda por nombre
- **Validaciones:**
  - Presencia de name
  - Unicidad de name

#### IngredientRestriction
- **Tabla:** ingredient_restrictions (tabla join)
- **Campos:**
  - `ingredient_id` (foreign key)
  - `restriction_id` (foreign key)
- **Asociaciones:**
  - `belongs_to :ingredient`
  - `belongs_to :restriction`

### 2. Restricciones Predefinidas (Seeds)

**14 Alergias de la UE:**
1. Gluten (Cereals)
2. Milk
3. Eggs
4. Fish
5. Crustaceans
6. Mollusks
7. Peanuts
8. Tree Nuts
9. Sesame
10. Celery
11. Mustard
12. Sulfites
13. Lupin
14. Soy

**6 Restricciones Religiosas:**
1. Halal
2. Kosher
3. Hindu
4. Buddhist
5. Vegan
6. Vegetarian

### 3. Controlador (IngredientsController)

**Ruta base:** `/ingredients`

**Acciones:**
- `index`: Listar todos los ingredientes con búsqueda
- `new`: Formulario para crear nuevo ingrediente
- `create`: Guardar nuevo ingrediente con restricciones
- `show`: Ver detalles de un ingrediente
- `edit`: Formulario para editar ingrediente
- `update`: Guardar cambios en el ingrediente
- `destroy`: Eliminar ingrediente

**Autorización:**
- Requiere `require_kitchen_manager_or_above!` (kitchen_manager o admin)

### 4. Vistas

#### Index (`app/views/ingredients/index.html.erb`)
- Lista de ingredientes en grid de tarjetas
- Búsqueda por nombre
- Muestra restricciones asociadas con badges de color
- Botón para crear nuevo ingrediente

#### New (`app/views/ingredients/new.html.erb`)
- Renderiza el formulario compartido

#### Edit (`app/views/ingredients/edit.html.erb`)
- Renderiza el formulario compartido

#### Show (`app/views/ingredients/show.html.erb`)
- Muestra nombre, descripción
- Lista todas las restricciones asociadas con su tipo
- Botones para editar, eliminar y volver

#### Form (`app/views/ingredients/_form.html.erb`)
- Campo de nombre (required)
- Campo de descripción (textarea)
- **Fieldset de restricciones:**
  - Sección: Intolerancias y Alergias (14 de la UE) - Checkboxes
  - Sección: Restricciones Religiosas - Checkboxes
- Validación de errores en formulario

### 5. Estilos (CSS)

**Archivo:** `app/assets/stylesheets/ingredients.css`

**Características:**
- Grid responsive para lista de ingredientes
- Cards con hover effects
- Badges de color para tipos de restricción
  - Amarillo/naranja: Intolerancias y alergias
  - Azul/verde: Restricciones religiosas
- Formulario bien estructurado con fieldsets
- Botones con estados (primary, secondary, danger, outline)
- Responsive design para mobile

### 6. Traducciones (I18n)

**Idioma:** Catalán (ca)

**Claves añadidas:**
```
ingredients.create.success
ingredients.destroy.success
ingredients.edit.title
ingredients.form.* (name, description, restrictions, etc.)
ingredients.index.* (title, search_placeholder, new_ingredient, etc.)
ingredients.new.title
ingredients.show.* (description, restrictions, edit, delete, etc.)
ingredients.update.success
restrictions.types.intolerance_allergy
restrictions.types.religious
```

### 7. Tests

**Archivo de tests de modelos:**
- `test/models/ingredient_test.rb` - 6 tests
- `test/models/restriction_test.rb` - 6 tests
- `test/models/ingredient_restriction_test.rb` - 3 tests

**Tests del controlador:**
- `test/controllers/ingredients_controller_test.rb` - Tests de CRUD y autorización

**Fixtures:**
- `test/fixtures/ingredients.yml`
- `test/fixtures/restrictions.yml`
- `test/fixtures/ingredient_restrictions.yml`

**Status:** ✅ Todos los tests de modelos PASAN (15/15)

## Acceso y Dashboard

### Para acceder como usuario "cuiner":
1. Accede a `http://localhost:3000`
2. Inicia sesión con:
   - **Usuario:** `cuiner`
   - **Contraseña:** `password`
3. En el dashboard principal verás una sección "Gestió d'Ingredients"
4. Haz clic en "Afegir ingredient" para crear un nuevo ingrediente
5. O haz clic en "Veure ingredients" para ver la lista de ingredientes

### Restricciones de Acceso:
- ✅ **kitchen_manager (cuiner):** Puede crear, ver, editar y eliminar ingredientes
- ✅ **admin:** Puede hacer todo lo que el kitchen_manager + gestionar usuarios
- ❌ **waiter (cambrer):** NO tiene acceso al formulario de ingredientes (solo ve la opción de waiter features)

## Migraciones Executadas

- `20260406101929_create_restrictions.rb` - Crea tabla restrictions con índice único en name
- `20260406101933_create_ingredients.rb` - Crea tabla ingredients con índice único en name
- `20260406101938_create_ingredient_restrictions.rb` - Crea tabla join ingredient_restrictions

## Rutas Configuradas

```ruby
resources :ingredients, constraints: { id: /\d+/ }
```

## Acciones de Seguridad

✅ **CSRF Protection:** Habilitado por defecto en Rails
✅ **Autorización:** `require_kitchen_manager_or_above!`
✅ **Validaciones:** En modelos y formulario
✅ **Strong Parameters:** `ingredient_params` con whitelist de atributos

## Base de Datos (Development/Test)

**SQLite3** - Storage: `/storage/development.sqlite3` y `/storage/test.sqlite3`

**Estadísticas:**
- Restrictions: 20 registros (14 de la UE + 6 religiosas)
- Seeds ejecutado correctamente

## Pendientes Opcionales

- [ ] Fotos/imágenes de ingredientes
- [ ] Historial de cambios
- [ ] Exportación de ingredientes (CSV, Excel)
- [ ] Integración con dish ingredients (cuando se implemente)

## Dashboard Actualizado

Se ha actualizado la página de inicio (`/home/index`) para mostrar un dashboard personalizado basado en el rol del usuario:

### Para kitchen_manager (cuiner):
- Sección "Gestió d'Ingredients" con opciones para:
  - "Afegir ingredient" - Crea un nuevo ingrediente
  - "Veure ingredients" - Ve la lista de todos los ingredientes

### Para admin:
- Tiene acceso a todo lo anterior PLUS
- Sección "Gestió d'Usuaris" con opción para gestionar usuarios

### Para waiter:
- Solo ve una sección "Funcionalitats del Cambrer" (sin acceso a ingredientes)

### Estilos CSS:
- Se agregó `app/assets/stylesheets/dashboard.css` con diseño responsive
- Grid layout que se adapta a móviles
- Tarjetas con hover effects
- Tipografía clara y jerarquía visual

---

**Fecha de implementación:** Abril 6, 2026
**Estado:** ✅ COMPLETO Y FUNCIONAL

