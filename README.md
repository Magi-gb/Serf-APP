# Serf — Sistema de gestió de menús per a restaurants

**Serf** és una aplicació web per ajudar restaurants a crear i adaptar menús tenint en compte les restriccions alimentàries, intoleràncies i preferències dels comensals.

## Context

Aquest projecte es desenvolupa en el marc de l'assignatura **AMEP** (Ampliació a l'Enginyeria del Programari) de la **Universitat Politècnica de Catalunya (UPC)**, a l'**Escola Politècnica Superior d'Enginyeria de Vilanova i la Geltrú (EPSEVG)**.

El client real és **Cal Blay**, una organització que gestiona diversos restaurants i necessita una eina per garantir la seguretat alimentària dels seus comensals. El problema que resolem: quan un grup arriba a un restaurant amb restriccions alimentàries diverses (al·lèrgies, intoleràncies, preferències religioses...), fer un menú compatible manualment és lent i propens a errors humans.

Serf permet:
- Gestionar el catàleg de **menús, plats i ingredients** amb les seves restriccions associades
- **Filtrar plats incompatibles** automàticament a partir de les restriccions del grup
- **Proposar alternatives** quan un ingredient d'un plat és substituïble
- Mostrar de forma clara totes les restriccions que pot incomplir un plat
- Gestionar **usuaris amb rols diferenciats**: administrador, responsable de cuina i cambrer

---

## Requisits previs

- **Ruby 3.1.2** — es recomana gestionar-lo amb [rbenv](https://github.com/rbenv/rbenv)
- **Bundler** — gestor de dependències de Ruby
- **SQLite3** — base de dades (inclosa per defecte en la majoria de sistemes)

### Instal·lar Ruby amb rbenv

```bash
# Instal·lar rbenv (si no el tens)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc

# Instal·lar ruby-build (plugin per instal·lar versions de Ruby)
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

# Instal·lar la versió correcta (definida a .ruby-version) i dependències
sudo apt update
sudo apt install build-essential ruby-dev libyaml-dev ruby-bundler libsqlite3-dev pkg-config zlib1g-dev
rbenv install 3.1.2
```

Un cop dins del directori del projecte, `rbenv` seleccionarà automàticament la versió `3.1.2` gràcies al fitxer `.ruby-version`.

---

## Preparar l'entorn de desenvolupament

```bash
# Clonar el repositori
git clone https://github.com/AMEP-EPSEVG/Serf-APP.git
cd Serf-APP

# Instal·lar les dependències
# Opció A — instal·lació estàndard (recomanada si tens permisos)
bundle config set --local path ./vendor/bundle
bundle install

# Opció B — instal·lació a un directori local (útil en entorns compartits)
bundle install --path vendor/bundle
```

> Si fas servir l'opció B, recorda que tots els comandaments de Rails s'han d'executar amb el prefix `bundle exec`.

```bash
# Crear i inicialitzar la base de dades
bin/rails db:create db:migrate

# Carregar les dades inicials (crea l'usuari admin per defecte)
bin/rails db:seed

# Alternativament, es pot fer servir el següent ordre, el qual crea la BBDD (db:create), carrega l'esquema (db:schema:load), executa les migracions (db:migrate) i els seeds (db:ssed)
bin/rails db:setup
```

---

## Executar l'aplicació

```bash
bin/rails server
# o si has instal·lat les gems localment:
bundle exec rails server
```

L'aplicació estarà disponible a [http://localhost:3000](http://localhost:3000).

---

## Migracions de la base de dades

Les migracions són fitxers Ruby (a `db/migrate/`) que defineixen canvis incrementals a l'esquema de la base de dades. Rails les executa en ordre cronològic.

### Comandes principals

```bash
# Executar totes les migracions pendents
bin/rails db:migrate

# Revertir l'última migració
bin/rails db:rollback

# Revertir les últimes N migracions
bin/rails db:rollback STEP=3

# Veure l'estat de les migracions (quines s'han executat i quines falten)
bin/rails db:migrate:status

# Recrear la base de dades des de zero (drop + create + migrate + seed)
bin/rails db:reset
```

### Crear una nova migració

```bash
# Crear una migració buida
bin/rails generate migration NomDeLaMigracio

# Crear una migració per afegir una columna
bin/rails generate migration AddColumnToTable column:type
# Exemple: bin/rails generate migration AddDescriptionToDishes description:text

# Crear una migració per crear una taula
bin/rails generate migration CreateTableName column1:type column2:type
# Exemple: bin/rails generate migration CreateDishes name:string price:decimal menu:references
```

Les migracions generades es troben a `db/migrate/` amb un timestamp al nom del fitxer (p. ex. `20260411120000_create_dishes.rb`). Edita el fitxer generat si cal ajustar detalls (índexs, valors per defecte, restriccions `null: false`, etc.) i després executa `bin/rails db:migrate`.

> **Important:** Un cop una migració ha estat pujada a la branca compartida, **no la modifiquis directament**. Crea una nova migració per corregir l'esquema.

---

## Executar els tests

El projecte usa **MiniTest**, el framework de tests per defecte de Rails.

```bash
# Tots els tests
bin/rails test

# Només tests de models
bin/rails test test/models/

# Només tests de controladors
bin/rails test test/controllers/

# Un test concret
bin/rails test test/models/user_test.rb
```

---

## Eines de qualitat de codi

```bash
# Linting (RuboCop)
bin/rubocop

# Anàlisi de seguretat estàtica
bin/brakeman

# Gestió de traduccions (i18n-tasks)
i18n-tasks missing            # Mostra claus de traducció que falten
i18n-tasks unused             # Mostra claus de traducció no utilitzades
i18n-tasks normalize          # Ordena i normalitza els fitxers de locale
i18n-tasks health             # Revisió completa de l'estat de les traduccions
```

---

## Internacionalització (I18n)

L'aplicació utilitza el sistema d'**internacionalització de Rails (I18n)** per gestionar tots els textos visibles a la interfície. L'idioma per defecte és el **català** (`:ca`).

### Com funciona

1. **Cap text hardcoded a les vistes.** Tots els textos visibles es defineixen com a claus de traducció als fitxers de locale.
2. A les vistes ERB s'utilitza el helper `t()` (abreviatura de `I18n.t()`), i als controladors/models `I18n.t()`.
3. Les traduccions es defineixen a `config/locales/ca.yml` (català) i `config/locales/en.yml` (anglès base). Les traduccions de Devise estan a `config/locales/devise.en.yml`.
4. La configuració del locale es troba a `config/application.rb`:
   - `config.i18n.default_locale = :ca`
   - `config.i18n.available_locales = [:ca]`

### Exemple

```erb
<%# A la vista: %>
<h1><%= t('home.index.title') %></h1>
```

```yaml
# A config/locales/ca.yml:
ca:
  home:
    index:
      title: "Benvingut a Serf"
```

### Validació amb i18n-tasks

El projecte inclou la gem **[i18n-tasks](https://github.com/glebm/i18n-tasks)** per mantenir la qualitat de les traduccions. Aquesta eina:

- **Detecta claus que falten** (`i18n-tasks missing`) — claus usades al codi però no definides als fitxers de locale
- **Detecta claus no utilitzades** (`i18n-tasks unused`) — claus definides als fitxers de locale però mai referenciades al codi
- **Normalitza** els fitxers YAML (`i18n-tasks normalize`) — ordena les claus alfabèticament i aplica un format consistent
- **Verifica interpolacions** — comprova que les variables dins les traduccions siguin consistents entre locales

La configuració d'i18n-tasks es troba a `config/i18n-tasks.yml`. A més, hi ha tests automatitzats a `test/i18n_test.rb` que verifiquen:
- No hi ha claus de traducció que faltin
- Els fitxers de locale estan normalitzats
- Les interpolacions són consistents

---

## Estàndards de desenvolupament

Tot el codi del projecte ha de seguir aquestes normes:

1. **Tot testat.** Cap codi es considera complet sense els seus tests corresponents (models, controladors, serveis, integracions). Codi sense tests és codi inacabat.
2. **Coherència d'estil (RuboCop).** Tot el codi ha de passar `bin/rubocop` amb zero ofenses. No s'accepten commits que introdueixin noves ofenses.
3. **Coherència visual.** La interfície ha de ser consistent amb els mockups i amb la resta de l'aplicació. Reutilitza les classes CSS i components existents sempre que sigui possible. Només crea estils nous quan sigui estrictament necessari — en aquest cas, el nom ha de seguir les convencions existents i l'estil s'ha d'ubicar a la secció corresponent del full d'estils.
4. **Sense estils en línia.** Mai fer servir atributs `style="..."` a les vistes ERB. Utilitza sempre classes o IDs definits als fulls d'estils.
5. **I18n obligatori.** Tots els textos visibles a la interfície han d'usar claus de traducció (`t()` / `I18n.t()`). No es permet text hardcoded a vistes ni missatges flash.
6. **DRY (Don't Repeat Yourself).** Evita codi duplicat. Extreu lògica compartida a helpers, partials, mòduls, concerns o serveis segons correspongui.
7. **Simplicitat.** No implementis funcionalitats especulatives ni abstraccions "per si de cas". Si no es necessita ara, no es construeix.
8. **Llegibilitat.** El codi ha de ser clar i fàcil de seguir. Noms descriptius, estructura lògica, sense complexitat innecessària.
9. **Sense codi mort.** No deixis codi comentat, fitxers buits generats automàticament, variables no utilitzades ni blocs obsolets. Si no es fa servir, s'elimina.
10. **Seguretat (Brakeman).** Tot el codi ha de passar l'anàlisi de seguretat estàtica amb `bin/brakeman` sense warnings nous. Executeu-lo abans de fer commit.
11. **Neteja de scaffold.** Després d'usar `rails generate`, elimina tot el que no es necessiti: fitxers `.jbuilder`, blocs `respond_to` amb `format.json`, vistes placeholder (`create.html.erb`, `update.html.erb`), rutes GET generades automàticament que dupliquin les de `resources`, i qualsevol altre fitxer generat que no s'utilitzi.
12. **Codi sempre en anglès.** Tots els noms de models, taules, columnes, variables, mètodes i classes han de ser en anglès. El català és només per a la interfície d'usuari (via I18n) i els missatges de commit.
13. **Control d'accés.** Els controladors han d'aplicar els guards del concern `Authorizable` (`require_admin!`, `require_kitchen_manager_or_above!`, etc.) segons correspongui. Avalua quines accions requereixen restricció en cada cas.
14. **Validacions als models.** Tot model ha de tenir les validacions necessàries per garantir la integritat de les dades. Si un camp és obligatori, ha de tenir també `null: false` a la migració. Si un camp ha de ser únic, a més del `validates :uniqueness` al model, cal afegir un índex amb constraint `UNIQUE` a la migració.
15. **Convencions REST.** Utilitza `resources` per definir les rutes. No creïs rutes manuals que dupliquin les que `resources` ja proporciona. Les accions del controlador han de seguir els verbs HTTP estàndard (GET, POST, PATCH, DELETE).
16. **`dependent: :destroy` a les associacions.** Tota relació `has_many` amb taula join ha de declarar `dependent: :destroy` per evitar registres orfes quan s'elimina el registre pare.

---

## Flux de treball amb Git

### Branques principals

- **`main`** — Conté el codi de la iteració finalitzada. Només rep merges des de `develop` quan la iteració està completada.
- **`develop`** — Branca de la iteració en curs. Conté les tasques completades i revisades. Es crea a partir de `main`.

### Branques de feature

Les branques de feature es creen a partir de `develop` i s'hi tornen a integrar mitjançant **Pull Request** amb revisió de codi.

```
main ← develop ← feature/la-meva-tasca
```

**Abans de demanar revisió (Pull Request)**, la branca de feature s'ha d'actualitzar fent merge de `develop` dins d'ella:

```bash
git checkout feature/la-meva-tasca
git merge develop
# Resol conflictes si n'hi ha
git push
```

### Dependències entre tasques

Si una feature o tasca depèn d'una altra, la branca de la tasca dependent s'ha de crear **a partir de la branca de la qual depèn**, no de `develop`:

```
develop ← feature/tasca-base ← feature/tasca-dependent
```

### Treball compartit en una mateixa feature

Quan diversos desenvolupadors treballen en la mateixa feature, hi ha dues estratègies:

1. **Branca compartida directa.** Tots treballen sobre la mateixa branca i gestionen els conflictes entre ells. Sempre s'ha d'usar `git pull --no-rebase` (mai `git pull --rebase`) per mantenir l'historial clar i evitar reescriure commits dels companys.

2. **Branca base comuna + branques individuals.** Es crea una branca compartida com a base, i cada desenvolupador crea la seva pròpia branca a partir d'aquesta per treballar en les seves tasques concretes. Això redueix conflictes i facilita la integració.

### Regles importants

- **Resoleu conflictes amb cura.** Reviseu sempre els conflictes detingudament per no sobreescriure la feina dels companys d'equip.
- **`git pull --no-rebase` sempre**, mai `git pull --rebase`. Rebase reescriu l'historial i pot provocar pèrdua de feina en branques compartides.
- **`git push --force` prohibit** per a desenvolupadors no experts que no sàpiguen exactament què estan fent. Especialment prohibit en branques compartides, i **absolutament prohibit a `main` i `develop`**.

---

## Estructura del projecte

```
app/
  controllers/    # Lògica de peticions HTTP
  models/         # Models ActiveRecord (User, Menu, Dish, Ingredient, Restriction...)
  views/          # Plantilles ERB
  services/       # Lògica de negoci complexa (SuggestionService, etc.)
config/
  routes.rb       # Definició de rutes RESTful
db/
  migrate/        # Migracions de la base de dades
test/             # Tests MiniTest
```

---

## Documentació de l'arquitectura

Diagrames d'arquitectura i flux disponibles a:
**https://github.com/AMEP-EPSEVG/Serf-Pages** (publicats via GitHub Pages)
