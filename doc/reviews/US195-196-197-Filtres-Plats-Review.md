# Revisió — branca `US195-196-197-Filtres-Plats`

**Funcionalitat:** Filtres a la llista de plats (per categoria, per restriccions a incloure, per restriccions a excloure).
**User stories:** US195, US196, US197 (tasks #195-197 + #211-216)
**Commit cap a la branca:** `640edb9` + merge de develop `810a199`
**Revisat per:** Claude (Opus 4.7) actuant com a *Operator Handoff*
**Data:** 2026-05-28

---

## 1 · Resum de la funcionalitat

Afegeix tres mecanismes de filtre a `dishes#index`:

- Filtre per **tipus de plat** (`entrant`, `primer`, `segon`, `postre`).
- Filtre **d'inclusió** per restriccions (mostrar només plats que contenen una determinada restricció a través dels seus ingredients).
- Filtre **d'exclusió** per restriccions (amagar plats que la contenen).

Codi tocat per la branca:

- `app/controllers/dishes_controller.rb` (+7 línies)
- `app/models/dish.rb` (+16 línies — 2 scopes)
- `app/views/dishes/index.html.erb` (+38 línies — toolbar de filtres)
- `test/controllers/dishes_controller_test.rb` (+29 línies — 5 tests d'integració)

Després del merge amb develop no hi ha hagut conflictes; Git ha fet el three-way automàticament.

---

## 2 · Estat dels gates de qualitat (després del merge)

| Gate | Resultat | Detall |
|---|---|---|
| `bin/rails test` | ❌ **FALLA** | 229 runs · **1 failure** · **8 errors** · 1 skip |
| `bin/rubocop` | ✅ Passa | 100 fitxers, cap ofensa |
| `bin/brakeman` | ✅ Passa | 0 advertències de seguretat |
| `i18n-tasks missing` | ❌ Falla | 2 claus inexistents: `filters.include`, `filters.exclude` |

Els errors a `bin/rails test` es resumeixen en un sol símptoma:
`ActionView::Template::Error: undefined method 'toggle_param_link'` en
`app/views/dishes/index.html.erb`. Una altra fallada al
`test/i18n_test.rb` reporta les dues claus i18n absents.

**Aquest estat és bloquejant: la branca no es pot fusionar a develop tal com està.**

---

## 3 · Troballes (findings)

### BUG-1 — La vista crida `toggle_param_link`, helper que ja no existeix

**Severitat:** crítica · **Categoria:** runtime

Develop ha substituït `toggle_param_link` per
`cycle_param_link` (commit `7faaef5`, "Filtres de restriccions tri-estat
amb un sol clic"). La branca encara genera tots els xips mitjançant
`toggle_param_link(mode: :include, ...)` i `toggle_param_link(mode:
:exclude, ...)`, així que cada GET a `/dishes` provoca un
`NoMethodError` quan Rails renderitza la plantilla.

Veure: `app/views/dishes/index.html.erb:21-49`.

**Resolució requerida:**
- Reemplaçar la doble fila d'inclusió/exclusió per una sola fila amb
  `cycle_param_link` (cicle neutre → exclou → inclou → neutre), igual
  que `app/views/menus/index.html.erb` i
  `app/views/ingredients/index.html.erb`.
- El filtre per tipus de plat NO és tri-estat (no té sentit "excloure
  l'entrant"). Caldrà decidir si es manté com a xip
  toggle-ON/OFF d'estat únic o si també es porta al cicle. La proposta
  d'aquesta revisió és **xip toggle binari** per als tipus, perquè la
  semàntica és diferent (selecció múltiple OR, sense estat
  d'exclusió).

### BUG-2 — Claus i18n `filters.include` / `filters.exclude` ja no existeixen

**Severitat:** crítica · **Categoria:** i18n

Quan develop va passar al cicle tri-estat, va substituir
`filters.{include,exclude}` per `filters.dietary_restrictions` i
`filters.next_action.{neutral,exclude,include}`. La branca de plats
encara escriu `<%= t("filters.include") %>` i `t("filters.exclude")`
com a etiquetes de fila. Després del merge:

- `i18n-tasks missing` reporta les dues claus com a "missing_used".
- `test/i18n_test.rb` falla per `to be empty`.

Veure: `app/views/dishes/index.html.erb:19` i `:39`.

**Resolució requerida:** desaparèixer les capçaleres "Inclou:"/"Exclou:"
(perquè un sol xip codifica els tres estats) i fer servir
`t("filters.dietary_restrictions")` com a etiqueta única.

### DESIGN-1 — La UX dels filtres no segueix el patró tri-estat

**Severitat:** alta · **Categoria:** disseny / coherència

L'instrucció de la revisió ha estat explícita: el filtre de plats ha
de tenir la mateixa estructura visual que el de menús i el
d'ingredients. A develop, tots dos fan servir una sola fila de xips
amb cicle de 3 estats. La branca implementa la versió antiga (dues
files separades, etiquetes "Inclou:" i "Exclou:"). A més,
`chip-include` i `chip-exclude` estan hard-codats com a CSS estàtic
en lloc d'utilitzar `data-state` que és el contracte actual del CSS
(`serf_components.css:257-275`).

**Resolució requerida:** veure BUG-1 — el fix mecànic per a BUG-1
resol també aquesta incoherència.

### TESTS-1 — Els tests d'integració són massa febles

**Severitat:** alta · **Categoria:** qualitat de proves

Els cinc tests nous a `test/controllers/dishes_controller_test.rb`
asserten exclusivament `assert_response :success`. Cap d'ells
comprova que el filtre realment filtri (quins plats apareixen,
quins no, què passa quan ningú no matcheja, etc.). Aquest nivell de
prova és l'equivalent a "compila i no peta" — no és cobertura
funcional.

A més, l'ID de restricció està codificat com a literal `"1"` o
`"2"` (`dishes_controller_test.rb:269`, `:274`, `:283`, `:284`). Si
les fixtures canvien d'ordre o se n'afegeix una al davant, els
tests aniran a parar a un altre lloc sense que ningú se n'adoni.

**Resolució requerida:**
- Asserts que comparin contingut renderitzat (ex.
  `assert_includes response.body, dishes(:paella).name` i
  `assert_not_includes` per al negatiu).
- Reemplaçar `"1"` per `restrictions(:gluten).id` i equivalents.

### TESTS-2 — Falten tests d'scope al model

**Severitat:** mitjana · **Categoria:** cobertura

Els scopes `filter_by_types` i `filter_by_restrictions` no tenen
proves directes a `test/models/dish_test.rb`. La convenció a la
resta del projecte (i a `test/models/menu_test.rb`,
`test/models/ingredient_test.rb`) és tenir tests d'scope dedicats
que cobreixin el camí feliç, els ids buits/nil i els casos límit
(múltiples ids amb OR, ingredients sense restriccions, etc.).

### NAMING-1 — Els scopes no segueixen la convenció del projecte

**Severitat:** mitjana · **Categoria:** consistència

`Ingredient` i `Menu` exposen `with_restrictions(ids)` i
`without_restrictions(ids)` com a parella de scopes encadenables. La
branca defineix:

- `filter_by_types(types)`
- `filter_by_restrictions(include_ids, exclude_ids)`

El segon és una funció que rep dos arguments alhora — fora del
patró del repo. La proposta de fix és dividir-lo en dos scopes
(`with_restrictions` i `without_restrictions`) per harmonitzar i
encadenar al controlador com fa `MenusController#index`.

`filter_by_types` també pot adoptar el patró `Array(types).compact_blank`
i un nom més curt (per exemple `of_types`), però és un detall
estètic.

### DEAD-1 — Paràmetre `exclude_dish_types` mai llegit

**Severitat:** baixa · **Categoria:** codi mort

Al xip de tipus de plat (`dishes/index.html.erb:21-29`),
`toggle_param_link` rep `exclude_param: "exclude_dish_types"`. Cap
scope del model llegeix mai aquest paràmetre. És herència d'haver
intentat reutilitzar el helper d'ingredients sense voler la
funcionalitat. Caldrà eliminar-ho durant el refactor del fix.

### POLISH-1 — `Restriction.all` sense `order(:name)`

**Severitat:** baixa · **Categoria:** UX

`@restrictions = Restriction.all` a `dishes_controller.rb:10`. Els
altres controladors fan `Restriction.order(:name)` per garantir un
ordre estable als xips. Inconsistent però sense impacte funcional.

### POLISH-2 — `.compact` redundant després de `.to_s`

**Severitat:** baixa · **Categoria:** codi

A `dish.rb:16-17`:

```ruby
include_ids = Array(include_ids).map(&:to_s).compact
exclude_ids = Array(exclude_ids).map(&:to_s).compact
```

`String#to_s` mai no retorna `nil`, així que el `.compact` final és
una no-op. La crida útil seria `.compact_blank` (treure cadenes
buides — útil quan els formularis injecten un valor buit), com fa
`Ingredient.with_restrictions`.

### YARD-1 — Documentació YARD absent als scopes nous

**Severitat:** baixa · **Categoria:** documentació

`CLAUDE.md` recomana ("SHOULD") YARD a la lògica nova. Els scopes
nous a `Dish` no en tenen, igual com no en tenen els d'`Ingredient` i
`Menu`. No és blocant; només es recull si el plantejament del
projecte vol pujar el nivell de docs.

---

## 4 · Pla de resolució (review-resolution commit)

S'apliquen tots els BUG i el DESIGN-1 (crítics + altes) i la majoria
de les troballes mitjanes/baixes. Concretament:

1. **Model `Dish`** — dividir `filter_by_restrictions` en dos
   scopes `with_restrictions` i `without_restrictions` seguint el
   patró d'`Ingredient`/`Menu`. Mantenir `filter_by_types` però
   netejar el `compact` → `compact_blank` i posar-li nom curt
   `of_types`.
2. **Controlador `DishesController#index`** — encadenar
   `.search(...).of_types(...).with_restrictions(...).without_restrictions(...)`;
   `@restrictions = Restriction.order(:name)`.
3. **Vista `dishes/index.html.erb`** — col·lapsar la doble fila en
   una sola fila tri-estat per restriccions amb
   `cycle_param_link`; mantenir la fila de tipus de plat com a
   toggle binari (xip ON/OFF) amb un helper específic o
   `toggle_param_link` si torna a entrar al codi (ara mateix
   eliminat). Reemplaçar `t("filters.include")` /
   `t("filters.exclude")` per `t("filters.dietary_restrictions")`.
4. **Tests** — afegir scope tests a `test/models/dish_test.rb`,
   enfortir els tests de controlador (asserts sobre body, ids per
   fixture).
5. **Codi mort** — eliminar el `exclude_dish_types` de la vista.

Després del fix, els gates han de tornar a verd:

- `bin/rails test` → 0 failures, 0 errors.
- `i18n-tasks health` → sense missing/unused.
- `bin/rubocop` i `bin/brakeman` ja estan en verd avui.

---

## 5 · Resum executiu

| Categoria | Estat |
|---|---|
| Compleix els estàndards de codi (rubocop) | ✅ |
| Compleix els estàndards de seguretat (brakeman) | ✅ |
| Sense literals inline a la UI | ✅ |
| Sense estils inline | ✅ |
| Tests passen | ❌ (8 errors + 1 failure) |
| Tests són suficients | ❌ (només `:success`) |
| i18n complet | ❌ (2 claus que falten) |
| Disseny coherent amb menús/ingredients | ❌ |

**Recomanació:** no fusionar. Aplicar la *review-resolution commit*
descrita a §4 i tornar a córrer els gates.
