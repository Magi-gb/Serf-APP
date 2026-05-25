# CRUD-de-protocols — Revisió de codi

**Branca:** `CRUD-de-protocols`
**Base:** `develop` (després d'integrar CRUD-de-Menú i CRUD-de-plats)
**Reviewer:** Thomas (assistit per Claude Code)
**Data:** 2026-05-11

---

## Resum

La branca afegeix el CRUD complet de `Protocol` (model, controller, vistes, rutes, migracions, seeds, fixtures, tests). El control d'accés és **admin-only per a write actions**; kitchen_manager i waiter només poden llistar i consultar.

**Conflictes resolts en la fusió amb develop:**
- `config/routes.rb` — afegir `resources :protocols` mantenint el `resources :plats` recent.
- `db/schema.rb` — regenerat a partir de les migracions (rerunning `db:migrate` sobre una BBDD neta) per recollir totes les taules (plat/menu + protocol).
- `app/assets/stylesheets/style_definition.css` — automerge net.

**Tests:** ✅ 185/185 (0 errors, 1 skip)
**Brakeman:** ✅ 0 warnings
**i18n missing:** ✅ 0
**i18n normalize:** ✅ OK
**RuboCop:** ✅ 0 ofenses

**Veredicte:** Es pot integrar a `develop` un cop corregides les troballes HIGH (estils en línia a `show` + columnes mortes a la taula `protocols`).

---

## BUG-1 — Estils en línia a `protocols/show.html.erb` (HIGH)

Dues ocurrències de `style="..."` que violen la regla CLAUDE.md:

```erb
<div class="detail-avatar" style="background-color: var(--color-bg-blue);">  <!-- línia 6 -->
...
<div class="desc-box" style="width: 100%; max-width: 600px;">                <!-- línia 12 -->
```

**Acció:**
- L'avatar: afegir un modificador `.detail-avatar-protocol` al `style_definition.css` que defineixi `--avatar-bg: var(--color-bg-blue)` (segueix el patró establert per `users/show.html.erb`, que fa servir `--avatar-bg` com a CSS custom property).
- El desc-box: fer servir la classe `.desc-box-bounded` ja existent (afegida durant la revisió de CRUD-de-Menú).

✅ Corregit.

## BUG-2 — Columnes `bg_color` i `icon_svg` mortes a la taula `protocols` (HIGH, FLAGGED)

La migració `20260429150254_add_visuals_to_protocols.rb` afegeix dues columnes a `protocols`:
- `bg_color` (string)
- `icon_svg` (text)

Però:
- `protocol_params` **no permet** aquests camps (commit `57c6355` *"Remove bg_color and icon_svg from protocol_params"* — eliminació intencional)
- El formulari (`_form.html.erb`) no els mostra
- La vista `show.html.erb` no els fa servir
- Hi ha un test (`protocol_update_test.rb:38-49`) que verifica explícitament que **no** es poden modificar via params
- A la vegada, `db/seeds.rb` **sí** que els fixa: `p.bg_color = data[:bg_color]` ⇒ inconsistència: les dades de seed són escrites però mai llegides

CLAUDE.md: *"No implementis funcionalitats especulatives... Si no es necessita ara, no es construeix."*

**No es corregeix automàticament** — eliminar columnes és destructiu. Cal una decisió de l'equip:
- **Opció A (recomanada)**: crear una migració `RemoveVisualsFromProtocols` i eliminar les columnes, treure-les també del seeds i de l'assertion `assert_select "input[name='protocol[bg_color]']", count: 0` del test (no caldria).
- **Opció B**: tornar a posar `bg_color`/`icon_svg` al `protocol_params`, al formulari i a la `show`. Implicaria reanalitzar el disseny del Protocol amb visuals com Restriction.

Flag per a resoldre abans de marcar la US com a Done.

## BUG-3 — `manifest.js` afegeix `link application.js` (LOW)

```js
//= link application.js
```

Aquest projecte utilitza **importmap-rails** (per CLAUDE.md i `Gemfile`), no Sprockets per al JS. La directiva no és necessària i pot crear confusió sobre quina és la pipeline de JS real.

**No es corregeix** sense saber si algú confia en ella. Cal verificar amb l'equip i, si no aporta res, treure-la en un commit posterior.

## BUG-4 — `users/show.html.erb` (heretat) també usa inline-style (LOW, FORA D'ABAST)

`<div class="detail-avatar" style="--avatar-bg: <%= user_avatar_color(@user) %>;">` — viola CLAUDE.md però és necessari per a aplicar un color dinàmic per usuari. Cal decidir entre:
- Acceptar el `style="..."` com a excepció documentada per a valors dinàmics de CSS variables
- O extreure a un helper que renderitzi un `<style>` inline (no millor)
- O usar `data-*` attributes amb un Stimulus controller

No és culpa d'aquesta branca; deixem una nota per a la propera revisió de convencions.

---

## Coses bones que aporta aquesta branca

- ✅ Tests molt complets: 28 entre model, controller i integració (autenticació, autorització, validacions, casos límit)
- ✅ Fixtures realistes (`allergy`, `cross_contamination`)
- ✅ Seeds tres protocols realistes
- ✅ Internacionalització completa (`ca.yml` + `en.yml`, incloent `errors.template.header` per als formularis)
- ✅ Auth correcte amb `require_admin!` per a write actions; lectura disponible per a kitchen_manager i waiter
- ✅ Maquetació consistent (`page-card` → `page-header` → `index-toolbar` → `list-card-group`) amb la resta de l'app

---

## Deute tècnic heretat

Mateixes anotacions que les altres branques:
- Manca documentació YARD a models i controladors
- Convenció `t()` vs `I18n.t()` inconsistent entre controllers (protocols usa `I18n.t`, menus/plats `t`) — només cosmètic, però convindria unificar

---

## Fitxers tocats per aquesta branca (únics, no compartits amb develop)

```
app/assets/config/manifest.js                  (+1 línia qüestionable)
app/assets/stylesheets/style_definition.css    (regla SVG dins avatars)
app/controllers/protocols_controller.rb        (nou)
app/models/protocol.rb                         (nou)
app/views/layouts/_sidebar.html.erb            (entrada protocols)
app/views/protocols/*.html.erb                 (nou, 5 vistes)
config/locales/{ca,en}.yml                     (claus protocols.*)
config/routes.rb                               (resources :protocols)
db/migrate/20260429120000_create_protocols.rb
db/migrate/20260429150254_add_visuals_to_protocols.rb
db/schema.rb                                   (regenerat)
db/seeds.rb                                    (+3 protocols)
test/                                          (model + controller + 2 integracions + fixture)
```

22 fitxers, +547 / −4.
