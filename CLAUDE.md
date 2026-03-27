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
| CSS | Plain CSS via Sprockets |
| Auth | Devise + RBAC (`Authorizable` concern) |
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
                                └── SQLite3 (dev/test) / MySQL (production)
                    └── ERB Views + Hotwire (Turbo Frames / Streams / Stimulus)
```

### Domain model (planned)

```
Menu          has_many :dishes
Dish          belongs_to :menu
              has_many :ingredients, through: :dish_ingredients
DishIngredient  (join table) — includes `essential` boolean flag
Ingredient    has_many :dishes, through: :dish_ingredients
              has_many :restrictions, through: :ingredient_restrictions
IngredientRestriction  (join table)
Restriction   (allergies, intolerances, preferences)
User          role: admin | kitchen_manager | waiter  (implemented)
```

Key rule: ingredients within a dish are classified as **essential** (blocking) or **replaceable** (substitutable). The suggestion engine uses this to filter or propose alternatives.

---

## Functional epics

| Epic | Description |
|---|---|
| CRUD Menus | Create/read/update/delete menus; filter dishes by dietary restriction |
| CRUD Dishes | Manage dishes with associated ingredients; show all incompatible restrictions |
| CRUD Ingredients | Manage ingredients; each ingredient can have N substitutes and N restrictions |
| CRUD Restrictions | Manage the restrictions catalog |
| Suggestion Engine | Given a set of restrictions, show compatible dishes; suggest alternatives |
| User Management | Authentication (done), roles (admin/kitchen_manager/waiter), permissions (done), user CRUD (pending) |

### Stakeholder roles

| Role | Type | Notes |
|---|---|---|
| Waiter | Direct user | Uses PDA or desktop; reads menus, uses suggestion engine |
| Head Cook | Direct user | Manages dish/ingredient catalog |
| Admin | Direct user | Full system access |
| Groups/Diners | Indirect | Their dietary needs drive the system |
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

**Authentication and authorization are implemented.** The remaining domain models (Menu, Dish, Ingredient, Restriction) and their CRUDs are not yet built.

What exists:
- **User model** with Devise (`database_authenticatable`), username login, role enum (`waiter`, `kitchen_manager`, `admin`)
- **Authorizable concern** — `require_admin!`, `require_kitchen_manager_or_above!` guards
- **Routes** — Devise sessions only (no registration, no password recovery); root → `home#index`
- **Login page** — styled to match the project mockup (plain CSS, dedicated `login` layout)
- **Seeds** — default admin user (`admin` / `password`)
- **Tests** — 22 tests covering User model, Authorizable concern, and authentication flows

---

## Development conventions

- **Language:** Catalan in UI and commit messages. **All model names, column names, variable names, and code must be in English** (e.g., `Dish`, `Restriction`, `User`).
- **Testing:** MiniTest. **Every feature, model, controller, service object, and file must have corresponding tests.** No code is considered complete without tests. This includes: model validations and associations, controller actions (happy path + error cases), service object logic, integration/system tests for user-facing features, and helper methods. Aim for comprehensive coverage — untested code is unfinished code. **All features must include fixtures** (`test/fixtures/`) for tests **and seeds** (`db/seeds.rb`) for the development database.
- **Definition of Done:** Implementation complete + **all tests written and passing** + no regressions + interface consistent with mockups + story marked Done in Taiga + relevant docs updated.
- **Style:** RuboCop (rubocop-rails-omakase). Run `bin/rubocop` before committing. **No new RuboCop offenses may be introduced — all code must pass `bin/rubocop` with zero offenses.**
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

- Catalan locale file needs to be added (`config/locales/ca.yml`)
