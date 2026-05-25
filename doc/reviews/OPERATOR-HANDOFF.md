# Handoff per a l'operador — Revisió de les 3 branques CRUD

**Data:** 2026-05-11
**Branques revisades i integrades a `develop`:** `CRUD-de-Menú`, `CRUD-de-plats`, `CRUD-de-protocols`
**Tots els tests passen** (185/185), **RuboCop neta** (0 ofenses), **Brakeman net** (0 warnings), **i18n** OK.

Aquest document recull el que **NO** s'ha corregit automàticament i requereix la teva decisió o seguiment manual. Els elements estan agrupats per criticitat. Llegir abans de tancar les US a Taiga.

---

## 🔴 CRÍTIC — Cal decidir abans de la pròxima iteració

### 1. Convenció d'anglès a models, taules i columnes (CLAUDE.md)

`CLAUDE.md` és explícit:
> *All model names, column names, variable names, and code must be in English (e.g., Dish, Restriction, User)*

**Violacions actuals a `develop`:**
- Model `Plat` → hauria de ser `Dish`
- Model `MenuPlat` → `MenuDish`
- Model `PlatIngredient` → `DishIngredient`
- Taules: `plats`, `menu_plats`, `plat_ingredients` → `dishes`, `menu_dishes`, `dish_ingredients`
- Columna `tipusPlat` → `dish_type` (a més, **és camelCase**: viola l'estil snake_case de Ruby/Rails)

**Per què no s'ha corregit aquí:** un rename d'aquesta magnitud afecta ~50 fitxers i totes les branques en curs (`CERCADORS-menú-plats`, ramificacions de feature en marxa). S'ha de fer en una iteració dedicada amb tot l'equip aturat.

**Acció recomanada:**
1. Crear una US "Renombrar Plat → Dish (i camelCase → snake_case)"
2. Coordinar amb totes les branques actives: fer merge a `develop` abans, congelar branches durant l'execució
3. Aplicar el rename amb un script (`bin/rails runner` + migracions per a la columna)

---

### 2. Bug funcional a `Menu.must_have_one_plat_of_each_type` (FLAGGED)

A `app/models/menu.rb`:
```ruby
def must_have_one_plat_of_each_type
  return if persisted? && plats.empty?
  # ...
end
```

Aquesta condició permet que un menú persistit **es quedi sense plats i segueixi essent vàlid**. No sembla intencional. Cap test ho cobreix explícitament.

**Acció:** Parlar amb l'autor (probablement Magí o Sofía, segons el git log) per confirmar si és un bug o si vol cobrir algun cas concret.
- Si és bug: treure la condició.
- Si és intencional: afegir un comentari explicant per què, i un test que ho documenti.

---

### 3. Columnes mortes `bg_color` i `icon_svg` a `protocols` (FLAGGED)

La migració `20260429150254_add_visuals_to_protocols.rb` crea aquestes columnes. Però:
- El controller no les permet
- El formulari no les exposa
- La vista no les mostra
- Un test verifica explícitament que **no** són accessibles
- Però `db/seeds.rb` **les omple** ⇒ inconsistència

**Acció:** Decidir entre:
- **A** (recomanat): nova migració `RemoveVisualsFromProtocols`, treure-les també del seeds i de l'assertion `count: 0` del test.
- **B**: posar-les altra vegada al `protocol_params`, formulari i vista — caldria redissenyar el Protocol amb visuals com Restriction.

---

## 🟡 IMPORTANT — Validar a la pròxima demo

### 4. Estructura HTML de `plats/index.html.erb` (ja corregida)

Tenia `<div class="page-card">` sense tancar. Corregit. **Revisar visualment** a la demo per confirmar que la maquetació no s'ha trencat.

### 5. Lògica de càrrega de plats al formulari de Menú (canviada)

Abans: el form feia `Plat.all` dins de la vista. Ara: el controller passa `@plats = Plat.order(:tipusPlat, :name)`.

**Conseqüència visual:** Els plats ara surten ordenats per tipus i nom dins de la mateixa llista (entrant → primer → segon → postre, alfabètic dins de cada tipus). Era el comportament desitjat? Si voleu agrupar visualment per tipus amb capçaleres, cal canviar la vista (ara és una sola llista plana de checkboxes amb un badge de tipus).

### 6. `manifest.js` afegeix `link application.js` (FLAGGED)

```js
//= link application.js
```

Aquest projecte usa **importmap-rails**, no Sprockets per al JS. Aquesta línia és sospitosa de ser inútil. **Verificar** amb qui l'ha afegida (a `CRUD-de-protocols`); si no aporta res, retirar-la en un commit posterior.

---

## 🟢 RECOMANACIONS — No urgent, però sí millorable

### 7. Documentació YARD

Cap mètode/classe té YARD docstrings. CLAUDE.md no ho exigeix però el README ho menciona com a recomanat. Es proposa afegir-ho com a US transversal.

### 8. Convenció `t()` vs `I18n.t()` als controllers

`ProtocolsController` usa `I18n.t(...)`. `MenusController` i `PlatsController` usen `t(...)`. Tots dos funcionen, però conviuen estils. Unificar (recomanació: `t(...)` és més idiomàtic a Rails).

### 9. Estil en línia a `users/show.html.erb` (HERETAT, FORA D'ABAST)

`<div class="detail-avatar" style="--avatar-bg: <%= user_avatar_color(@user) %>;">` viola CLAUDE.md però és necessari per a aplicar color dinàmic per usuari. Cal decidir:
- Acceptar com a excepció documentada per a valors dinàmics de CSS custom properties
- Extreure a un Stimulus controller que llegeixi `data-avatar-color` i apliqui `style.setProperty`

### 10. Tres reviews creats a `doc/reviews/`

Conservar-los; serveixen com a registre de decisions. Si voleu, podeu enllaçar-los des de les US tancades a Taiga.

---

## Resum d'estat post-revisió

| Branca | Merge OK? | Tests | RuboCop | Brakeman | i18n | Comentaris |
|---|---|---|---|---|---|---|
| `CRUD-de-Menú` | ✅ ja a develop | 160/160 | 0 | 0 | OK | 12 troballes corregides |
| `CRUD-de-plats` | ✅ ja a develop | 160/160 | 0 | 0 | OK | 4 troballes corregides |
| `CRUD-de-protocols` | ✅ ja a develop | 185/185 | 0 | 0 | OK | 2 troballes corregides; 2 flagged |

**Commits afegits a develop** (sense comptar els merges):
- `[Review] CRUD-de-Menú: revisió de codi i deute tècnic`
- `[Review-Fix] CRUD-de-Menú: aplicar troballes de la revisió`
- `[Review] CRUD-de-plats: revisió de codi post-merge develop`
- `[Review-Fix] CRUD-de-plats: corregir HTML mal balancejat i whitespace`
- `[Review] CRUD-de-protocols: revisió de codi i deute tècnic`
- `[Review-Fix] CRUD-de-protocols: eliminar estils en línia a show`

---

## Acció final recomanada per a l'operador

1. **Validar visualment** a la demo els canvis dels punts 4 i 5 (HTML structure i ordre de plats al form de menú).
2. **Decidir** sobre els punts 1, 2 i 3 (CRÍTICS) abans de la pròxima iteració.
3. **Confirmar** amb el responsable de `CRUD-de-protocols` el punt 6 (`manifest.js`).
4. **Tancar les US a Taiga** referenciant els documents de revisió a `doc/reviews/`.
