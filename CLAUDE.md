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
| Testing | MiniTest (unit, functional, integration) |
| I18n QA | i18n-tasks (detect missing/unused keys) |
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
- **Commit message task reference:** Every commit message must include the Taiga task reference in the format `(Task #XX)` at the end of the subject line (e.g., `Afegeix CRUD de plats (Task #42)`). If you are not sure which task number applies to the current work, ask the developer before committing.
- **I18n:** All user-facing strings must use Rails I18n (`t()` in views, `I18n.t()` in controllers/models). **No hardcoded text in views or flash messages.** Translations go in `config/locales/ca.yml`. Default locale is `:ca`. Use `i18n-tasks` to detect missing or unused translation keys (see tests in `test/i18n_test.rb` and config in `config/i18n-tasks.yml`).
- **Testing:** MiniTest. **Every feature, model, controller, service object, and file must have corresponding tests.** No code is considered complete without tests. This includes: model validations and associations, controller actions (happy path + error cases), service object logic, integration tests, and helper methods. Aim for comprehensive coverage — untested code is unfinished code. **All features must include fixtures** (`test/fixtures/`) for tests **and seeds** (`db/seeds.rb`) for the development database. **Do NOT create system tests** (Capybara/Selenium). We do not use `test/system/` or `bin/rails test:system`. Test user-facing features through controller/integration tests instead.
- **Definition of Done:** Implementation complete + **all tests written and passing** + no regressions + interface consistent with mockups + story marked Done in Taiga + relevant docs updated.
- **Style:** RuboCop (rubocop-rails-omakase). Run `bin/rubocop` before committing. **No new RuboCop offenses may be introduced — all code must pass `bin/rubocop` with zero offenses.**
- **Security:** Run `bin/brakeman` before committing.
- **CSS:** **No inline styles.** Always use CSS classes or IDs defined in stylesheets. Never use `style="..."` attributes in ERB views or helpers. **Prefer existing classes and components** — avoid adding new styles whenever possible. If new styles are strictly necessary, ensure they are placed in the correct stylesheet section, follow the existing naming conventions, and are generic and reusable rather than one-off.
- **No API responses:** The API is out of scope. **Do not include Jbuilder templates, `respond_to :json`, `render json:`, or any JSON API endpoints.** Controllers should only serve HTML views.
- **Service objects:** Business logic (especially the suggestion engine) goes in `app/services/`, not in controllers or models.
- **DRY (Don't Repeat Yourself):** Avoid duplicated code. Extract shared logic into helper methods, partials, modules, concerns, or service objects as appropriate. Before writing new code, check if similar functionality already exists in the codebase.
- **Simplicity:** Keep code simple and clean. Do not implement speculative features or abstractions "just in case." If it's not needed now, don't build it. Do not leave dead code, unused files, empty generated files, or commented-out blocks in the codebase — delete them.
- **Documentation:** All project documentation goes in `doc/`. Documentation intended only for LLM agents (implementation plans, context notes, etc.) goes in `doc/claude/`. Do not create documentation files in the project root or other directories.
- **Scaffold cleanup:** After using `rails generate`, remove everything that is not needed: `.jbuilder` files, `respond_to` blocks with `format.json`, placeholder views (`create.html.erb`, `update.html.erb`), auto-generated GET routes that duplicate those from `resources`, and any other generated file that is not used.
- **Authorization:** Controllers should apply `Authorizable` concern guards (`require_admin!`, `require_kitchen_manager_or_above!`, etc.) as appropriate. Evaluate which actions require restriction on a case-by-case basis.
- **Model validations:** Every model must have the necessary validations to ensure data integrity. If a field is required, it must also have `null: false` in the migration. If a field must be unique, in addition to `validates :uniqueness` in the model, add an index with a `UNIQUE` constraint in the migration.
- **REST conventions:** Use `resources` to define routes. Do not create manual routes that duplicate what `resources` already provides. Controller actions must follow standard HTTP verbs (GET, POST, PATCH, DELETE).
- **`dependent: :destroy` on associations:** Every `has_many` relationship with a join table must declare `dependent: :destroy` to avoid orphaned records when the parent record is deleted.

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
i18n-tasks missing            # Show missing translation keys
i18n-tasks unused             # Show unused translation keys
i18n-tasks normalize          # Sort and normalize locale files
i18n-tasks health             # Full i18n health check
```

