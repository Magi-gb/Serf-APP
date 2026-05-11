# Revisió — branca `CERCADORS-menú-plats`

**PR origen:** AMEP-EPSEVG#20 (US22 — alternatives d'ingredients)
**Commit cap a develop:** Merge `582ed88` (merge commit)
**Revisat per:** Claude (Opus 4.7) actuant com a *Operator Handoff*
**Data:** 2026-05-11

> **Nota important sobre el nom de la branca.** El branch original
> contenia el caràcter accentuat `ú` (`CERCADORS-menú-plats`). El nom
> de la **funcionalitat** lliurada NO és "cercadors de menú i plats"
> sinó **alternatives d'ingredients** (US22). El títol de la branca és
> probablement un error. Els fitxers commits, doc/, models i tests
> confirmen que la funcionalitat real és el sistema d'alternatives.

---

## 1 · Resum de la funcionalitat

Afegeix una **autoreferència many-to-many** a `Ingredient` per declarar
substituts. Regles:

- L'alternativa **no pot afegir noves restriccions** respecte
  l'ingredient original (validació de model).
- Un ingredient no pot ser alternativa de si mateix (validació + check
  constraint al DB).
- `kitchen_manager` i `admin` poden crear/eliminar alternatives; els
  cambrers només poden consultar-les.

Tot el codi nou:
- `db/migrate/20260501065010_create_ingredient_alternatives.rb`
- `app/models/ingredient_alternative.rb`
- `app/controllers/ingredient_alternatives_controller.rb`
- Vista `app/views/ingredients/show.html.erb` (secció + formulari)
- I18n keys a `ca` i `en`
- Documentació `doc/ingredient_alternatives.md`
- Tests model + controller + fixtures

---

## 2 · Conflictes de merge i com s'han resolt

| Fitxer | Conflicte | Resolució |
|---|---|---|
| `config/routes.rb` | HEAD tenia el flat `resources :ingredients`; la branca el converteix en bloc amb `resources :alternatives, controller: ...` anidat | Conservada la versió anidada de la branca (necessària per al CRUD nou) |
| `db/schema.rb` | Versió desfasada de la branca (`2026_05_01_065010` vs `2026_05_11_130000` de develop) + manca de taules `dishes` / `menus` / `menu_dishes` / `dish_ingredients` | Regenerat manualment combinant les taules de develop + `ingredient_alternatives` de la branca; versió final = `2026_05_11_130000` |
| `config/locales/ca.yml` + `en.yml` | Branques afegeixen claus diferents al mateix node | Fusionades alfabèticament: `activerecord.errors.models.ingredient_alternative.*` + `ingredients.show.{add_alternative_*, alternatives_title, confirm_remove_alternative, no_alternatives, no_available_alternatives, remove_alternative}` |
| `app/views/ingredients/show.html.erb` | Branca usava classes llegades (`.list-card-group`, `.list-card`, `.btn-danger`, `.form-group`, `.form-actions`, `.btn-primary`) + barra `.detail-actions` duplicada al peu | Portada la funcionalitat a la layout de dues columnes del nou disseny: nova card `Alternatives` dins de la columna principal, amb files `.row` + `.btn btn-secondary btn-sm` per eliminar, divisor (`.divider`) i formulari inline amb `.select` + `.btn btn-primary`. Eliminada la barra inferior d'accions (Delete/Edit ja viuen al topbar) |

Migracions: ambdues branques toquen `db/migrate/` però amb timestamps
diferents → `bin/rails db:migrate` les aplica seqüencialment sense
problemes.

---

## 3 · Troballes (findings)

### BUG-1 — Eliminar un ingredient referenciat com a alternativa falla

**Severitat:** alta · **Categoria:** integritat de dades

`Ingredient` declara `has_many :ingredient_alternatives, dependent: :destroy`,
però **només** cobreix els registres on aquest ingredient és l'**original**.
Si un ingredient `A` és declarat alternativa de `B`, en eliminar `A`
intentarem treure la fila però la `dependent: :destroy` no s'aplica
(viu en una direcció diferent de l'associació). La migració defineix
`foreign_key: { to_table: :ingredients }` sense cascada → **violació de
clau forana** i SQL error.

**Reproducció:** crea `A` i `B`, afegeix `A` com a alternativa de `B`,
intenta destruir `A` → falla.

**Correcció aplicada en un commit posterior:**
afegir una segona associació inversa amb `dependent: :destroy`:

```ruby
has_many :referencing_alternatives,
         class_name: "IngredientAlternative",
         foreign_key: :alternative_id,
         dependent: :destroy
```

### BUG-2 — N+1 al càlcul d'alternatives candidates

**Severitat:** mitjana · **Categoria:** rendiment

`IngredientsController#show` construeix `@alternative_ingredients` així:

```ruby
candidates = Ingredient.includes(:restrictions).where.not(id: excluded_ids).order(:name)
@alternative_ingredients = candidates.select do |candidate|
  (candidate.restriction_ids - ingredient_restriction_ids).empty?
end
```

`includes(:restrictions)` preconté les restriccions, però
`candidate.restriction_ids` **no fa servir l'associació prepoblada** —
genera una consulta SQL extra per cada candidat (N+1).

**Correcció aplicada:**

```ruby
(candidate.restrictions.map(&:id) - ingredient_restriction_ids).empty?
```

així reutilitzem les restriccions ja carregades per `includes(:restrictions)`.

### DEBT-1 — Naming d'i18n verbós

**Severitat:** baixa · **Categoria:** estil

Les claus `ingredients.show.add_alternative_label`, `..._prompt`,
`..._submit`, `..._title` es podrien anidar sota
`ingredients.show.add_alternative.{label, prompt, submit, title}` per
agrupar millor. No bloqueja; deixat com a *follow-up*.

### DEBT-2 — `destroy` lookup pel `alternative_id` (no per `id` del join)

**Severitat:** baixa · **Categoria:** convenció REST

`IngredientAlternativesController#destroy` cerca amb
`find_by!(alternative_id: params[:id])`. La ruta resta convencional
(`DELETE /ingredients/:ingredient_id/alternatives/:id`), però el `:id`
de la URL **no** és l'identificador del registre de la taula
`ingredient_alternatives` sinó l'identificador de l'ingredient
alternatiu. La doc ho explicita
(`doc/ingredient_alternatives.md` §Endpoints) però sorpren a qui
construeixi URLs manualment. Acceptable; *follow-up* opcional.

### DEBT-3 — Cobertura de tests

**Severitat:** mitjana · **Categoria:** qualitat

Faltes detectades als tests existents:

- Controller: no es prova el camí `create` amb una alternativa
  **invàlida** (que afegeix restriccions noves) — només el cas vàlid.
  Es perd la cobertura del `alert: ...full_messages.to_sentence`.
- Controller: no es prova l'autoreferència (passar `alternative_id`
  igual a `ingredient_id`).
- Controller: no es prova el cas duplicat (segona crida amb la mateixa
  parella → hauria de retornar amb error per validació d'unicitat).
- Model: no es prova `validates :alternative_id, uniqueness: { scope: :ingredient_id }`.
- Cap test cobreix la regressió de BUG-1 (eliminar un ingredient que
  és alternativa).

**Acció:** afegits tres tests nous (model + controller) com a part del
commit de fixes (veure §4).

### OK — Aspectes correctes

- Migració amb índex únic `(ingredient_id, alternative_id)` i check
  constraint `ingredient_id != alternative_id`.
- Foreign keys explícites (`foreign_key: { to_table: :ingredients }`).
- Autorització via `require_kitchen_manager_or_above!` al controller
  d'alternatives (heretat de `Authorizable`).
- Localització en català/anglès al missatge d'error de validació
  (`activerecord.errors.models.ingredient_alternative.attributes.alternative.cannot_add_restrictions`).
- Documentació clara a `doc/ingredient_alternatives.md` (en català, com
  pertoca per a user-facing).

---

## 4 · Fixes aplicats en aquest cicle de revisió

| # | Fix | Fitxers tocats |
|---|---|---|
| 1 | BUG-1 — Cascade quan un ingredient referenciat com a alternativa s'elimina | `app/models/ingredient.rb`, `test/models/ingredient_test.rb` |
| 2 | BUG-2 — N+1 al càlcul de candidates | `app/controllers/ingredients_controller.rb` |
| 3 | DEBT-3 — Tests addicionals | `test/controllers/ingredient_alternatives_controller_test.rb`, `test/models/ingredient_alternative_test.rb` |

Estat dels quality gates després dels fixes (sense push):

- ✅ Tests
- ✅ RuboCop
- ✅ Brakeman
- ✅ i18n-tasks health (no missing, no unused, normalitzat)

---

## 5 · Follow-ups recomanats (no aplicats)

- DEBT-1: agrupar les claus i18n d'`add_alternative_*`.
- DEBT-2: replantejar el path del recurs perquè `:id` apunti al
  registre de la taula `ingredient_alternatives`; o documentar més
  visiblement al codi del controller que `:id` és l'ingredient
  alternatiu, no el join.
- Decidir si el branch hauria de fer servir un nom més precís
  (`alternatives-ingredients` o similar) — el repo actual el conserva
  com `CERCADORS-menú-plats` per traçabilitat amb Taiga.
