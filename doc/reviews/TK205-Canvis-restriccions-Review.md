# Revisió — branca `TK205-Canvis-restriccions`

**Funcionalitat:** Reclassificació de restriccions (rename `religious` → `diet`, addició de `preference`), filtres de restriccions als menús i plats, vista d'estadístiques per restricció, icona "chart" a la sidebar.
**Tasks:** TK205, #134, #135, #136
**Commit HEAD de la branca (pre-merge):** `3a5d691`
**Merge de develop realitzat:** `a1f0dca` (conflicte a `db/schema.rb` version — resolt mantenint la versió de develop `2026_05_31_120000`)
**Revisat per:** Claude (Opus 4.8) actuant com a revisor de codi
**Data:** 2026-05-31

---

## 1 · Resum de la funcionalitat

La branca inclou cinc grups de canvis:

1. **TK205 — Reclassificació de restriccions**: addició del valor `preference: 2` a l'enum `restriction_type` + migració de check constraint a `IN (0,1,2)`. El rename `religious → diet` (ja completat a develop) no s'ha completat correctament a la branca.
2. **Filtres als menús** (tasca #246/#247): scopes `with_restrictions` / `without_restrictions` a `Menu`, encadenament al controlador, filter chips a la vista de menús.
3. **Filtres tri-estat als plats** (post-merge): `select_param_link` per al filtre de tipus de plat, `cycle_param_link` per al filtre de restriccions a la vista de plats.
4. **Vista d'estadístiques** (tasques #134, #135, #136): nou `StatisticsController`, vista `statistics/index.html.erb`, ruta GET, icona "chart" a la sidebar.
5. **Refactor filter chips**: `toggle_param_link` → `cycle_param_link` (cicle neutral → exclude → include → neutral).

---

## 2 · Estat dels gates de qualitat (post-merge)

| Gate | Resultat | Detall |
|---|---|---|
| `bin/rails test` | ❌ **FALLA** | 259 runs · **1 failure** · 0 errors · 1 skip |
| `bin/rubocop` | ❌ **FALLA** | 5 ofenses (totes auto-correctable) |
| `bin/brakeman` | ✅ Passa | 0 advertències |
| `i18n-tasks health` | ✅ Passa | Cap clau absent ni de sobra |

**Estat bloquejant: la branca no es pot fusionar tal com està.**

---

## 3 · Troballes (findings)

### BUG-1 — Test de StatisticsController no s'autentica

**Severitat:** crítica · **Categoria:** test / runtime

L'únic test de `StatisticsControllerTest` fa `get statistics_url` sense haver iniciat sessió. `before_action :require_admin!` redirigeix a `/users/sign_in` (302), fent fallar el test.

```
StatisticsControllerTest#test_should_get_index:
Expected response to be <2XX: success>, but was <302: Found>
```

A més, el test només comprova `assert_response :success` — no verifica que el contingut renderitzat sigui correcte.

**Resolució requerida:**
- Iniciar sessió com a usuari admin al setup (seguint el patró dels altres tests del projecte).
- Afegir assertions sobre el contingut: noms de restriccions, contadors de plats/menús.

---

### BUG-2 — RuboCop: 5 ofenses

**Severitat:** crítica · **Categoria:** estil / qualitat

```
app/controllers/statistics_controller.rb:25 — Final newline missing
app/models/restriction.rb:2 — Space inside { missing
app/models/restriction.rb:2 — Space inside } missing
db/migrate/20260530095600_update_restriction_type_check_constraint.rb:10 — Final newline missing
test/controllers/statistics_controller_test.rb:8 — Final newline missing
```

Totes les ofenses son auto-correctable. Per CLAUDE.md, zero ofenses és obligatori.

---

### BUG-3 — Inconsistència enum `religious` vs `diet` (enum incomplet)

**Severitat:** alta · **Categoria:** funcionalitat / integritat de dades

Develop ha completat el rename `religious → diet` (commit `[Fix] Consolida els tipus de restricció a 2`). Però després del merge, `app/models/restriction.rb` té:

```ruby
enum :restriction_type, {intolerance_allergy: 0, religious: 1, preference: 2}
```

Mentre que `app/helpers/serf_design_helper.rb:114` té:
```ruby
when "diet" then "diet"
```

I `app/views/ingredients/_form.html.erb:42` té:
```ruby
diet: [ t("ingredients.form.diet_restrictions"), "diet" ]
```

El filtre `r.restriction_type == "diet"` mai retorna `true` perquè el tipus és `"religious"`. **El grup "Dieta" de la form d'ingredients no mostra cap restricció.** A més:
- `.tag-diet` i `.coverage-bar-fill-diet` (CSS) mai s'activen.
- `restriction_tag_kind` retorna `"preference"` per a totes les restriccions de tipus `religious` (cau a l'`else`).

**Resolució requerida:**
- Canviar l'enum a `{ intolerance_allergy: 0, diet: 1, preference: 2 }`.
- Les fixtures i el schema guarden enters (0, 1, 2) — no cal migrar dades.
- Actualitzar seeds: `:religious` → `:diet` (Halal, Kosher, Hindú, Budista).

---

### I18N-1 — ca.yml té traduccions en anglès per als tipus de restricció

**Severitat:** alta · **Categoria:** i18n / UX

`config/locales/ca.yml` (restriction types section):
```yaml
types:
  intolerance_allergy: Intolerance/Allergy   # ← anglès!
  preference: Preference                      # ← anglès!
  religious: Religious                        # ← anglès!
```

Develop té les traduccions correctes en català (`diet: Dieta`, `intolerance_allergy: Intolerància/Al·lèrgia`). Però el merge no ha resolt correctament la divergència perquè la branca afegeix `preference` i `religious` en anglès mentre develop tenia `diet` en català.

**Resolució requerida:**
- `intolerance_allergy: Intolerància/Al·lèrgia`
- `diet: Dieta` (reanomenat de `religious` un cop resolt BUG-3)
- `preference: Preferència`
- Eliminar la clau `religious:`.

---

### STYLE-1 — Inline styles a `statistics/index.html.erb`

**Severitat:** alta · **Categoria:** CSS / estil

Línies 37 i 42:
```html
<div class="row" style="justify-content: space-between;">
```

Violació directa del CLAUDE.md: "No inline styles. Always use CSS classes." No existeix cap classe de utilitat per a `justify-content: space-between` al projecte.

Línia 14–16:
```html
<span class="restr-bubble"
  style="--restr-bg: <%= restriction.bg_color... %>;
         --restr-fg: var(--text-on-brand);">
```

L'ús de CSS custom properties via inline style per passar colors dinàmics és el patró establert del component `.restr-bubble` (el CSS ja defineix `background: var(--restr-bg, ...)` com a API del component). Tècnicament és inline style però és la única manera de passar valors dinàmics de BD a CSS sense JavaScript. Es considera una excepció justificada — però `--restr-fg` és un valor constant que no necessita inline style i hauria d'anar a la classe CSS.

**Resolució requerida:**
- Línies 37 i 42: afegir classe `.row-spread` a `serf_components.css` i usar-la.
- Línia 16: eliminar `--restr-fg: var(--text-on-brand);` de l'inline style i afegir-lo a `.restr-bubble` al CSS.

---

### DEAD-1 — `app/helpers/statistics_helper.rb` buit

**Severitat:** mitjana · **Categoria:** codi mort

```ruby
module StatisticsHelper
end
```

Generat per scaffold, no conté cap mètode. Per CLAUDE.md: "After using rails generate, remove everything that is not needed." Cap vista ni test el necessita.

**Resolució requerida:** Eliminar el fitxer i qualsevol referència.

---

### DOC-1 — DESIGN-GAP comment obsolet a `_form.html.erb`

**Severitat:** baixa · **Categoria:** documentació interna

`app/views/ingredients/_form.html.erb:72-73`:
```erb
<%# DESIGN-GAP: design has a 4th group "Preferències" — Restriction enum only has
    intolerance_allergy + diet. Need to add a `preference` value (and EFSA flag). %>
```

`preference` ja ha estat afegit a l'enum. El comentari ha d'actualitzar-se.

---

### DOC-2 — `doc/to_review.txt` — fitxer de treball accidentalment commitejat

**Severitat:** baixa · **Categoria:** codi mort / arxius innecessaris

Conté una còpia d'un `git log` de branques alienes a TK205. No aporta informació rellevant al repositori i no segueix el propòsit de la carpeta `doc/`.

**Resolució requerida:** Eliminar el fitxer.

---

### DOC-3 — UML desactualitzat

**Severitat:** baixa · **Categoria:** documentació

`doc/uml-class-diagram.puml` mostra `RestrictionType` amb `religious = 1` en lloc de `diet = 1`.

**Resolució requerida:** Actualitzar a `diet = 1` i afegir `preference = 2`.

---

## 4 · Aspectes positius

- Els nous scopes `with_restrictions` / `without_restrictions` a `Menu` i `Dish` segueixen exactament el patró establert a `Ingredient` — coherència exemplar.
- `cycle_param_link` i `select_param_link` ben separats (semàntica tri-estat vs binari) i documentats amb comentaris clars.
- Tests de filtre als controladors usen fixtures per nom (`restrictions(:gluten)`) i fan assertions sobre el contingut renderitzat — qualitat correcta.
- La migració `20260530095600` és idempotent i segura: remove + add constraint sense tocar dades.
- `bin/brakeman` passa sense advertències.
- `i18n-tasks health` passa sense claus absents (les claus existeixen, tot i que alguns valors estan en anglès a ca.yml — veure I18N-1).

---

## 5 · Pla de resolució (review-resolution commit)

S'apliquen tots els BUG, STYLE i DEAD. Les DOC s'apliquen parcialment.

1. **Model** — `restriction.rb`: `religious: 1` → `diet: 1`.
2. **Locales** — `ca.yml`: clau `religious:` → `diet: Dieta`; corregir `intolerance_allergy` i `preference` a català. `en.yml`: `religious:` → `diet: Diet`.
3. **Seeds** — `:religious` → `:diet` per a Halal, Kosher, Hindú, Budista.
4. **Test** — `statistics_controller_test.rb`: sign_in com a admin, assertions sobre contingut.
5. **RuboCop** — auto-correct (trailing newlines + brace spaces).
6. **CSS** — afegir `.row-spread` a `serf_components.css`; eliminar `--restr-fg` de l'inline style de la vista.
7. **Vista estadístiques** — substituir `style="justify-content: space-between;"` per `class="row-spread"`.
8. **Dead code** — eliminar `app/helpers/statistics_helper.rb`.
9. **DOC-1** — actualitzar DESIGN-GAP comment a `_form.html.erb`.
10. **DOC-2** — eliminar `doc/to_review.txt`.
11. **DOC-3** — actualitzar UML.

---

## 6 · Resum executiu

| Categoria | Estat |
|---|---|
| Tests passen | ❌ (1 failure) |
| Tests suficients | ⚠️ (StatisticsController té 0 assertions útils) |
| RuboCop | ❌ (5 ofenses) |
| Brakeman | ✅ |
| Sense literals inline | ✅ |
| Sense inline styles | ❌ (statistics view) |
| Sense codi mort | ❌ (StatisticsHelper buit) |
| i18n complet | ✅ (claus existents, però valors en anglès a ca.yml) |
| Coherència enum / helper / CSS / form | ❌ (`religious` vs `diet`) |

**Recomanació:** no fusionar fins aplicar la review-resolution commit.
