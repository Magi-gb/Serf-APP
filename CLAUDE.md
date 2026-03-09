# CLAUDE.md — Serf-APP

## Project overview

**Serf** is a restaurant menu management web application developed as a university project for the AMEP subject at UPC (EPSEVG). It helps restaurants create and adapt menus considering diners' dietary restrictions, intolerances, and preferences.

**Client:** Cal Blay (restaurant cooperative)
**Team:** Alonso López Néstor, Cardenas Paucar Jean Carlos, Castillo Moyano Arnau, Garcia Bedós Magí, Lago Bonilla Guillem, Peña Narváez Sofía, Scalise Belusini Thomas

**Related repos:**
- `Serf-APP` (this repo) — Ruby on Rails application
- `Serf-Pages` — Static documentation site (GitHub Pages): architecture and flux diagrams

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Ruby on Rails 7.2.2 (MVC) |
| Ruby version | 3.1.2 |
| Database | SQLite3 (dev/test) |
| Frontend | ERB views + Hotwire (Turbo + Stimulus) |
| JS loading | importmap-rails (no bundler) |
| CSS | `application.css` via Sprockets (CSS framework TBD: Bootstrap / Bulma / Tailwind) |
| Auth | Devise (to be added) + RBAC |
| Testing | MiniTest + Capybara + Selenium (headless Chrome) |
| Security | Brakeman, RuboCop (rubocop-rails-omakase) |
| Server | Puma (port 3000) |

---

## Architecture — MVC layers

```
Client (Browser)
  └── HTTP/S requests
        └── Router (config/routes.rb) — RESTful resources
              └── Auth middleware (Devise / RBAC)
                    └── ActionController
                          ├── SuggestionService (service object)
                          └── ActiveRecord Models
                                └── MySQL/MariaDB
                    └── ERB Views + Hotwire (Turbo Frames / Streams / Stimulus)
```

### Domain model (planned)

```
Menu          has_many :plats
Plat          belongs_to :menu
              has_many :ingredients, through: :plat_ingredients
PlatIngredient  (join table) — includes `imprescindible` boolean flag
Ingredient    has_many :plats, through: :plat_ingredients
              has_many :restriccions, through: :ingredients_restriccions
IngredientsRestriccio  (join table)
Restriccio    (allergies, intolerances, preferences)
Usuari        role: admin | cuiner | cambrer
```

Key rule: ingredients within a dish are classified as **imprescindible** (blocking) or **substituïble** (replaceable). The suggestion engine uses this to filter or propose alternatives.

---

## Functional epics

| Epic | Description |
|---|---|
| CRUD Menús | Create/read/update/delete menus; filter dishes by dietary restriction |
| CRUD Plats | Manage dishes with associated ingredients; show all incompatible restrictions |
| CRUD Ingredients | Manage ingredients; each ingredient can have N substitutes and N restrictions |
| CRUD Restriccions alimentàries | Manage the restrictions catalog |
| Motor de suggeriments | Given a set of restrictions, show compatible dishes; suggest alternatives |
| Gestió d'usuaris | Authentication, roles (admin/cuiner/cambrer), permissions, CRUD |

### Stakeholder roles

| Role | Type | Notes |
|---|---|---|
| Cambrer | Direct user | Uses PDA or desktop; reads menus, uses suggestion engine |
| Responsable de Cuina | Direct user | Manages dish/ingredient catalog |
| Administrador | Direct user | Full system access |
| Grups/Comensals | Indirect | Their dietary needs drive the system |
| EFSA | External third party | EU food safety regulations |

---

## Scope

**IN scope:**
- Grouping of dietary restrictions
- Pre-arranging menus for diner groups in advance

**OUT of scope:**
- Reservation and schedule management
- Stock management
- Supplier management
- Billing and payments

**Maybe (undecided):**
- Warning when no dish exists for a diner
- Allergy alerts when ingredient is essential
- Religious/preference restrictions treated same as allergies
- Order management (pass to kitchen)

---

## Current state of the codebase

The app is a **fresh Rails 7.2.2 scaffold** — no custom models, controllers, views, or routes have been implemented yet beyond Rails defaults. No migrations exist. Everything needs to be built.

Key files already present:
- `config/routes.rb` — only health check and PWA routes
- `app/controllers/application_controller.rb` — only `allow_browser versions: :modern`
- `app/models/application_record.rb` — base class only
- `app/views/layouts/application.html.erb` — base layout (no nav yet)
- `db/seeds.rb` — empty

---

## Development conventions

- **Language:** Catalan in UI, comments, and commit messages. Model/variable names in Catalan where they match the domain (e.g., `Plat`, `Restriccio`, `Usuari`).
- **Testing:** MiniTest. Write tests for all models (validations, associations) and controllers.
- **Definition of Done:** Implementation complete + basic functional tests passing + no regressions + interface consistent with mockups + story marked Done in Taiga + relevant docs updated.
- **Style:** RuboCop (rubocop-rails-omakase). Run `bin/rubocop` before committing.
- **Security:** Run `bin/brakeman` before committing.
- **Service objects:** Business logic (especially the suggestion engine) goes in `app/services/`, not in controllers or models.

---

## Common commands

```bash
bin/rails server              # Start dev server on port 3000
bin/rails db:migrate          # Run migrations
bin/rails db:seed             # Seed database
bin/rails db:reset            # Drop, create, migrate, seed
bin/rails generate model ...  # Generate a model
bin/rails generate controller ...
bin/rails test                # Run all tests
bin/rails test test/models/   # Run model tests only
bin/rubocop                   # Lint
bin/brakeman                  # Security scan
```

---

## Pending decisions

- CSS framework: Bootstrap vs. Bulma.io vs. Tailwind CSS (to be evaluated based on team learning curve and design requirements)
- Auth library: Devise vs. Rodauth
- Catalan locale file needs to be added (`config/locales/ca.yml`)
