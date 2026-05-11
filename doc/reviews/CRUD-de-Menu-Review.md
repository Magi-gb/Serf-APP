# CRUD-de-Menú — Revisió de codi

**Branca:** `CRUD-de-Menú`
**Base:** `develop`
**Reviewer:** Thomas (assistit per Claude Code)
**Data:** 2026-05-11

---

## Resum

La branca afegeix els CRUDs de **Menu** i **Plat** amb les seves associacions (`MenuPlat`, `PlatIngredient`), més estils CSS per als checkboxes, entrades a la sidebar i a la home, i traduccions i18n. La merge amb `develop` (només el commit `vendor/bundle` al `.gitignore`) ha sigut neta — cap conflicte.

**Tests:** ✅ 149/149 (0 errors, 1 skip)
**Brakeman:** ✅ 0 warnings
**i18n missing:** ✅ 0
**i18n normalize:** ✅ OK
**RuboCop:** ❌ 8 offenses (4 auto-correctable)

**Veredicte:** Es pot integrar a `develop` un cop arreglades les troballes CRITICAL i HIGH. Hi ha violacions estructurals (convenció de codi en anglès) que afecten tota la base; es marquen com a deute tècnic per a tractar en una iteració posterior coordinada amb la resta de branques.

---

## Convencions de l'abast d'aquesta revisió

**Es corregeixen** (commit de fix): codi mort, estils en línia, helpers buits, ofenses de RuboCop, falta de `null: false`/`UNIQUE` que siguin un-line, scaffold sobrant, tests buits.

**Es marquen però no es corregeixen** (refactor coordinat amb la resta del projecte): renoms `Plat → Dish`, `tipusPlat → tipus_plat`. Refer-ho aquí implicaria tocar ~48 fitxers i trencaria les branques en curs (`CRUD-de-plats`, ramificacions de feature).

---

## BUG-1 — `MenuDatesValidator` és codi mort (CRITICAL)

`app/validators/menu_dates_validator.rb` referencia columnes que **no existeixen** a l'esquema (`starts_on`, `ends_on`, `starts_on_input`, `ends_on_input`). Les columnes `starts_on` i `ends_on` van ser eliminades per la migració `20260502122822_simplify_menus.rb`. Els atributs `_input` mai han existit.

A més, el validador **no està registrat enlloc**: `Menu` no fa `validates_with MenuDatesValidator` ni `include`.

**Acció:** Eliminar `app/validators/menu_dates_validator.rb` completament. ✅ Corregit.

## BUG-2 — Estils en línia a les vistes show (CRITICAL)

CLAUDE.md prohibeix `style="..."` a les vistes ERB. Apareix a:
- `app/views/menus/show.html.erb:9` → `style="width: 100%; max-width: 600px;"`
- `app/views/plats/show.html.erb:9, 14, 19` → `style="width: 100%; max-width: 600px;"` (×3)

**Acció:** Afegir una classe `desc-box-bounded` (o ampliar `.desc-box`) al `style_definition.css` i eliminar els atributs `style=...`. ✅ Corregit.

## BUG-3 — Consultes a BBDD dins de les vistes (HIGH)

Les vistes executen `Plat.all` i `Ingredient.all` directament:
- `app/views/menus/_form.html.erb:22` → `Plat.all`
- `app/views/plats/_form.html.erb:34` → `Ingredient.all`

A més, `MenusController#new`/`edit` carrega `@plats_by_type` però la vista no l'utilitza — el carregador és codi mort i el form fa la seva pròpia query.

**Acció:** Fer servir variables d'instància del controlador (`@plats_by_type` per menus, `@ingredients` per plats). ✅ Corregit.

## BUG-4 — `MenusController#show` té una línia inert (LOW)

```ruby
def show
  @menu
end
```

La línia `@menu` no fa res: és una referència a la variable que ja està assignada al `before_action :set_menu`. Codi mort.

**Acció:** Deixar el cos de `show` buit (`set_menu` ja assigna `@menu`). ✅ Corregit.

## BUG-5 — `PlatsHelper` buit (LOW)

`app/helpers/plats_helper.rb` només conté `module PlatsHelper; end`. CLAUDE.md: *"No deixis... fitxers buits generats automàticament"*.

**Acció:** Eliminar el fitxer. ✅ Corregit.

## BUG-6 — Lògica sospitosa a `must_have_one_plat_of_each_type` (MEDIUM, FLAGGED)

A `app/models/menu.rb:21`:

```ruby
return if persisted? && plats.empty?
```

Aquesta línia diu: *"si el menú ja està guardat i no té cap plat, salta la validació"*. Resultat: un menú persistit pot tenir zero plats i seguir essent vàlid. No sembla intencional — probablement era un intent de manejar algun cas concret que ja no existeix.

**Comportament observat amb la guarda actual:** un menú creat amb plats que després perd tots els plats no falla la validació en una nova `update`. No hi ha test que ho cobreixi explícitament.

**No es corregeix automàticament** — pot ser intencional. Cal confirmar amb l'autor (Magí/Sofía?). Si és un bug, treure la condició; si és intencional, documentar amb un comentari el motiu.

## BUG-7 — RuboCop falla amb 8 ofenses (HIGH)

Totes a `test/models/menu_test.rb`, regla `Layout/SpaceInsideArrayLiteralBrackets`:

```
test/models/menu_test.rb:5, 19, 28, 48 (16 ocurrències, 4 auto-correctables)
```

Exemple: `[plats(:olivas).id, ...]` hauria de ser `[ plats(:olivas).id, ... ]` (estil rubocop-rails-omakase).

**Acció:** Executar `bundle exec rubocop -A`. ✅ Corregit.

## BUG-8 — `test/models/plat_ingredient_test.rb` és un stub buit (HIGH)

Només conté codi comentat (`# test "the truth" do ...`). CLAUDE.md: *"untested code is unfinished code"*. El model té `belongs_to :plat, :ingredient` i `validates :plat_id, uniqueness: { scope: :ingredient_id }` que cal cobrir.

**Acció:** Afegir tests de la validació d'unicitat i associacions. ✅ Corregit.

## BUG-9 — `Plat` no té tests de validació (MEDIUM)

`test/models/plat_test.rb` només testeja associacions i `dependent: :destroy`, però no:
- `validates :name, presence: true`
- `validates :description, presence: true`
- L'enum `tipusPlat` (valors permesos)

**Acció:** Afegir tests per a les validacions de presència i per a l'enum. ✅ Corregit.

## BUG-10 — Falta `null: false` a `plats.name` (MEDIUM)

`db/migrate/20260428091323_create_plats.rb` declara `t.string :name` sense `null: false`. CLAUDE.md: *"Si un camp és obligatori, ha de tenir també `null: false` a la migració"*. El model ja valida `presence: true`.

**Acció:** Afegir una nova migració que apliqui `null: false`. ✅ Corregit (no modifico la migració original perquè ja és en una branca compartida).

## BUG-11 — Falta índex `UNIQUE` a `plat_ingredients` (MEDIUM)

`PlatIngredient` valida `validates :plat_id, uniqueness: { scope: :ingredient_id }` però la taula no té un índex únic sobre `(plat_id, ingredient_id)`. CLAUDE.md: *"Si un camp ha de ser únic... cal afegir un índex amb constraint UNIQUE a la migració"*.

`menu_plats` sí que té l'índex compost únic; cal aplicar el mateix patró aquí.

**Acció:** Afegir una nova migració que crei l'índex `UNIQUE`. ✅ Corregit.

## BUG-12 — Línia en blanc extra a `app/models/ingredient.rb` (LOW)

Dues línies en blanc entre `has_many ... plats` i `scope :search`. No és una ofensa de RuboCop, només pulcritud.

**Acció:** Eliminada. ✅ Corregit.

---

## Deute tècnic — NO es corregeix en aquesta revisió

### DEBT-A — Models i columnes en català (CRITICAL per CLAUDE.md, però fora d'abast)

CLAUDE.md és explícit: *"All model names, column names, variable names, and code must be in English (e.g., Dish, Restriction, User)"*.

Violacions:
- Model `Plat` → ha de ser `Dish`
- Model `MenuPlat` → ha de ser `MenuDish`
- Model `PlatIngredient` → ha de ser `DishIngredient`
- Taula `plats` → `dishes`
- Taula `menu_plats` → `menu_dishes`
- Taula `plat_ingredients` → `dish_ingredients`
- Columna `tipusPlat` → `dish_type` (a més, **és camelCase**, contra l'estil snake_case de Ruby)
- Enum `tipusPlats` (mètode auto-generat) → `dish_types`

**Per què no es corregeix aquí:** un rename d'aquesta magnitud toca ~48 fitxers d'aquesta branca + qualsevol branca germana (`CRUD-de-plats`, `CERCADORS-menú-plats`, ramificacions en curs). Cal coordinar amb tot l'equip en una iteració dedicada.

**Recomanació:** Crear una US per al rename complet (Dish/Restriction/Ingredient) **abans** que aquest deute creixi més.

### DEBT-B — Manca documentació YARD

Cap mètode/classe té docstrings YARD. Es proposa afegir-ne com a tasca transversal a tot el projecte (no només aquesta branca).

### DEBT-C — Hi ha `DishIngredient` planejat amb flag `essential` segons CLAUDE.md

El domain model de CLAUDE.md inclou `DishIngredient` amb columna `essential` (boolean). El `PlatIngredient` actual **no té aquesta columna**. Quan es construeixi l'engine de suggeriments caldrà afegir-la.

---

## Fitxers tocats per aquesta branca (resum)

```
app/controllers/         menus_controller.rb, plats_controller.rb, restrictions_controller.rb (només re-format trivial)
app/models/              menu.rb, plat.rb, menu_plat.rb, plat_ingredient.rb, ingredient.rb
app/views/menus/         _form, edit, index, new, show
app/views/plats/         _form, edit, index, new, show
app/views/home/          index (afegeix accés a menús)
app/views/layouts/       _sidebar (entrada menús i plats)
app/views/shared/        _field_error
app/assets/stylesheets/  style_definition.css (afegits checkboxes i badges)
config/locales/          ca.yml, en.yml
config/routes.rb         resources :menus, resources :plats
db/migrate/              create_plats, create_plat_ingredients, create_menus, simplify_menus, add_tipusPlat_to_plats, create_menu_plats
db/schema.rb, db/seeds.rb
test/                    tests de controllers, models i fixtures
```

48 fitxers, +1635 / −8.
