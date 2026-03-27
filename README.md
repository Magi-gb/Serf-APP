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

Per als tests de sistema (Capybara + Selenium):

```bash
bin/rails test:system
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
