# US113-116 — Revisión de código (Ingredients CRUD completo)

**Rama:** `US113-114-115-116-Ingredients-CRUD`
**Base:** `develop`
**Fecha:** 2026-04-11

---

## BUG-1 — Vistas `create.html.erb`, `update.html.erb` y `destroy.html.erb` no deberían existir (HIGH)

Se han creado tres ficheros de vista vacíos (solo contienen un salto de línea):
- `app/views/ingredients/create.html.erb`
- `app/views/ingredients/update.html.erb`
- `app/views/ingredients/destroy.html.erb`

Las acciones `create`, `update` y `destroy` redirigen en éxito o re-renderizan `new`/`edit` en error. Nunca renderizan su propia plantilla. Estos ficheros son innecesarios y se generaron por error.

**Acción requerida:** Eliminar los tres ficheros.

## BUG-2 — Falta la clave I18n `en.ingredients.delete.action` (HIGH)

El test `I18nTest#test_no_missing_keys` falla porque la clave `ingredients.delete.action` existe en `ca.yml` (valor: `"Acció"`) pero no en `en.yml`. La vista `delete.html.erb` la utiliza como cabecera de columna de la tabla.

**Acción requerida:** Añadir `action: Action` bajo `en.ingredients.delete` en `config/locales/en.yml`.

## BUG-3 — 4 offenses de RuboCop (HIGH)

`bin/rubocop` reporta 4 offenses (3 autocorregibles): espacios en arrays y trailing empty lines en `test_test_helper.rb` y tests.

**Acción requerida:** Ejecutar `bin/rubocop -A` y verificar que queda a 0 offenses.

## BUG-4 — Título de `application.html.erb` revierte a literal hardcoded (MEDIUM)

El título del layout principal se ha revertido de `t("app_name")` a `"Serf App"` hardcoded (línea 4). Esto viola la convención de I18n del proyecto.

**Acción requerida:** Sustituir `"Serf App"` por `t("app_name")`.

## BUG-5 — `ca.yml` contiene literal en castellano (MEDIUM)

La clave `ca.errors.messages.record_invalid` tiene el valor `"Registro inválido"`, que está en castellano, no en catalán. Debería ser `"Registre no vàlid"` o similar.

**Acción requerida:** Traducir al catalán.

## BUG-6 — Acceso a ingredients restringido a kitchen_manager para todas las acciones (MEDIUM)

El `IngredientsController` aplica `before_action :require_kitchen_manager_or_above!` **sin excepciones** — esto bloquea `index` y `show` también para los camareros. En la rama anterior (revisión CRUD82-84), se había implementado `except: %i[index show]` para permitir lectura a todos los roles.

Hay que decidir si los camareros deben poder ver los ingredientes. Si la respuesta es sí (que era el comportamiento anteriormente acordado), falta `except: %i[index show]`.

Los tests actuales verifican que un waiter es redirigido en `index` — si se cambia el guard, los tests deben actualizarse.

**Acción requerida:** Confirmar la decisión de acceso. Si los camareros deben poder consultar, añadir `except: %i[index show]`.

## BUG-7 — Eliminado `RestrictionsController` y todas sus vistas (MEDIUM)

Se ha eliminado el controlador de restricciones (`RestrictionsController`), sus vistas y sus tests, junto con la ruta `resources :restrictions`. Esto significa que ya no existe un CRUD de restricciones en la aplicación — las restricciones solo se pueden gestionar desde seeds.

Si esto es intencional (las restricciones se consideran datos estáticos gestionados por seeds), debería documentarse. Si no, es una regresión.

**Acción requerida:** Confirmar si la eliminación es intencional. Si no, restaurar.

## BUG-8 — Eliminada validación `password_confirmation` del modelo User (MEDIUM)

Se ha eliminado `validates :password, confirmation: true, if: :password_required?` del modelo `User`, junto con los tests correspondientes en `user_test.rb` y `users_controller_test.rb`. Esto permite crear usuarios con contraseñas que no coinciden en el formulario de confirmación.

**Acción requerida:** Restaurar la validación y los tests, o justificar la eliminación.

## BUG-9 — Eliminada validación `description` de Ingredient y Restriction (LOW)

- `Ingredient` ya no valida `description` (y de hecho la columna `description` ha sido eliminada de la tabla — correcto si el modelo ya no la necesita).
- `Restriction` ha cambiado: se eliminó `validates :description, presence: true` y se sustituyó `bg_color`/`icon_svg` por `restriction_type` (enum). La migración también cambió la estructura de la tabla.

Esto es un cambio de dominio significativo: las restricciones ahora tienen un `restriction_type` (intolerance_allergy / religious) en lugar de color e icono. Es coherente, pero debería confirmarse que no rompe la funcionalidad de restricciones preexistente.

**Acción requerida:** Verificar que el cambio de esquema de `restrictions` es intencional y no rompe nada.

## BUG-10 — Ruta custom `GET ingredients-delete` no es RESTful (LOW)

Se ha añadido una ruta custom `get "ingredients-delete"` con su propia acción `delete` y vista `delete.html.erb`. Esto rompe las convenciones REST de Rails. La eliminación normalmente se gestiona desde la vista `show` o `index` con un botón DELETE.

No es un bug funcional, pero añade complejidad innecesaria (una acción y vista extra) y no sigue los patrones del proyecto.

**Acción requerida:** Considerar si la vista de eliminación separada es necesaria o si se puede gestionar desde `index`/`show`.

## BUG-11 — Inline styles en vistas de usuarios (LOW)

Las vistas `users/index.html.erb` (línea 15) y `users/show.html.erb` (línea 2) contienen `style="background-color: ..."` inline. Esto viola la convención de CSS del proyecto: "No inline styles."

**Acción requerida:** Mover el color dinámico a una variable CSS (como `style="--avatar-bg: ..."` + clase CSS que use la variable) o usar clases por rol.

## BUG-12 — Fixtures de `ingredient_restrictions` vaciados (LOW)

El fichero `test/fixtures/ingredient_restrictions.yml` se ha vaciado (solo contiene un comentario). Los tests crean las asociaciones dinámicamente en vez de usar fixtures. Esto es funcional, pero rompe el patrón del proyecto donde los fixtures proporcionan datos base.

También se han eliminado los fixtures con nombres descriptivos (`Wheat flour`, `Whole milk`) y reemplazado por genéricos (`Milk`, `Bread`).

**Acción requerida:** Menor — confirmar si el cambio de estrategia (sin fixtures de join) es intencional.

## BUG-13 — Tests de `dependent: :destroy` eliminados (LOW)

Los tests que verificaban que eliminar un `Ingredient` o `Restriction` destruye los `IngredientRestriction` asociados han sido eliminados. La funcionalidad (`dependent: :destroy`) sigue presente en los modelos, pero ya no hay cobertura de test para ella.

**Acción requerida:** Restaurar tests de `dependent: :destroy` para ambos modelos.

## BUG-14 — Eliminada supresión de warnings de SQLite fork-safety (LOW)

Se ha eliminado `SQLite3::ForkSafety.suppress_warnings!` de `test_helper.rb`. Si los tests se ejecutan en paralelo con SQLite (que es el caso: `parallelize(workers: :number_of_processors)`), esto puede producir warnings en la consola.

**Acción requerida:** Verificar si los tests producen warnings de fork-safety. Si es así, restaurar la línea.

## BUG-15 — Documentación generada por IA excesiva (LOW)

Se han añadido 5 ficheros de documentación que parecen generados por IA y no aportan valor sobre lo que ya documenta `CLAUDE.md`:
- `CHANGES_SUMMARY.md` (140 líneas)
- `IMPLEMENTATION_COMPLETE.md` (215 líneas)
- `QUICKSTART.md` (170 líneas)
- `doc/INGREDIENTS_ACCESS_GUIDE.md` (204 líneas)
- `doc/ingredients_feature.md` (244 líneas)

Además, se han eliminado las reviews previas (`doc/reviews/CRUD45-Review.md` y `doc/reviews/CRUD82-84-Review.md`).

**Acción requerida:** Eliminar los ficheros de documentación generada que no aporten valor. Restaurar las reviews eliminadas.

## BUG-16 — `Devise::Test::IntegrationHelpers` movido fuera de `ActiveSupport::TestCase` (LOW)

El include de `Devise::Test::IntegrationHelpers` se ha movido de `ActiveSupport::TestCase` a `ActionDispatch::IntegrationTest`. Esto es técnicamente más correcto (Devise recomienda incluirlo en integration tests, no en todos los tests), pero puede romper tests de modelo que necesiten autenticación.

**Acción requerida:** Menor — verificar que ningún test de modelo necesita helpers de Devise.

---

## Resumen

La rama completa el CRUD de ingredients con vistas funcionales, búsqueda, restricciones categorizadas por tipo (intolerance_allergy / religious), una página de eliminación dedicada y un dashboard. Es un avance significativo.

Los problemas principales son:
1. **Test suite roto** — falta una clave I18n en `en.yml` (`ingredients.delete.action`)
2. **RuboCop offenses** — 4 offenses detectadas
3. **Vistas vacías innecesarias** — `create.html.erb`, `update.html.erb`, `destroy.html.erb`
4. **Decisión de acceso ambigua** — camareros bloqueados de `index`/`show` (cambio respecto a la revisión anterior)
5. **Eliminación de `RestrictionsController`** — sin CRUD de restricciones
6. **Eliminación de validación `password_confirmation`** — regresión de seguridad

**Recomendación:** Corregir BUG-1 a BUG-3 antes de merge (son los que rompen CI). Discutir BUG-6, BUG-7 y BUG-8 con el equipo para confirmar si son intencionales.
