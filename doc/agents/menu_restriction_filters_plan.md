# Menu restriction filters — implementation plan

## Goal

Bring the same tri-state restriction filter chip UI we shipped for
ingredients to the menus index, with backend logic that traverses
the menu → dish → ingredient → restriction join chain.

Per the user's spec:

- **Inclusion**: a menu passes when it has AT LEAST ONE dish that has
  AT LEAST ONE ingredient carrying AT LEAST ONE of the included
  restrictions.
- **Exclusion**: a menu passes when NONE of its dishes' ingredients
  carry ANY of the excluded restrictions.

Frontend behavior is identical to the ingredients page (single row of
tri-state chips, cycle neutral → exclude → include → neutral). The
URL contract uses the same query-param names — `include_restrictions[]`
and `exclude_restrictions[]` — so the helper `cycle_param_link` is
reused unchanged.

## Current state (verified)

- `app/controllers/menus_controller.rb:5-7` — `index` action is just
  `Menu.search(params[:search]).order(name: :asc)`. No restriction
  filtering, no `@restrictions`.
- `app/views/menus/index.html.erb:21-24` — toolbar exists but the
  filter slot is an empty `<div></div>` placeholder.
- `app/models/menu.rb` — has `has_many :dishes, through: :menu_dishes`
  and `scope :search`. No restriction-aware scope yet.
- Join chain present in schema:
  `menus → menu_dishes → dishes → dish_ingredients → ingredients →
  ingredient_restrictions → restrictions`. Indexes on every join FK
  exist (`db/schema.rb:19-21, 50-51, 67-69`).
- Reference scopes on `Ingredient` (`app/models/ingredient.rb:19-28`)
  show the convention: `with_restrictions` uses
  `joins(...).where(... IN ids).distinct`, `without_restrictions` uses
  `where.not(id: joins(...).where(... IN ids).select(...))`.
- Reusable parts already in place after the previous task:
  - `cycle_param_link` helper in `app/helpers/serf_design_helper.rb`.
  - CSS for `.chip[data-state="…"]` and the lighter hover variants in
    `app/assets/stylesheets/serf_components.css:257-275`.
  - i18n keys `filters.dietary_restrictions`,
    `filters.next_action.{neutral,exclude,include}`, `filters.clear`
    in `config/locales/ca.yml` and `en.yml`.
- Fixtures:
  - Only one `ingredient_restriction` fixture today: `bread_gluten`.
  - `weekly_menu` contains `olivas` → `bread` (gluten). The other
    `tasting_menu` dishes have no `dish_ingredients` rows. We'll need
    a couple more fixtures to exercise multi-restriction cases.
- No existing menu-filter controller or model tests.

## Design

### Model: two scopes on `Menu`

```ruby
# app/models/menu.rb
scope :with_restrictions, ->(ids) {
  ids = Array(ids).compact_blank
  next all if ids.empty?
  joins(dishes: { ingredients: :ingredient_restrictions })
    .where(ingredient_restrictions: { restriction_id: ids })
    .distinct
}

scope :without_restrictions, ->(ids) {
  ids = Array(ids).compact_blank
  next all if ids.empty?
  where.not(
    id: joins(dishes: { ingredients: :ingredient_restrictions })
          .where(ingredient_restrictions: { restriction_id: ids })
          .select(:id)
  )
}
```

Notes:

- `joins(dishes: { ingredients: :ingredient_restrictions })` produces
  inner joins through `menu_dishes → dishes → dish_ingredients →
  ingredients → ingredient_restrictions`. We don't need to mention the
  join tables explicitly because Rails resolves them via the existing
  `has_many :through` chain.
- `.distinct` on the include scope: a menu containing multiple
  ingredients tied to the same restriction would otherwise appear
  multiple times.
- Multi-restriction semantics is **OR**: a single include set of
  `[gluten, lactose]` returns any menu containing gluten OR lactose,
  mirroring `Ingredient.with_restrictions`. Same for exclude: a menu
  is filtered out if it touches ANY excluded restriction. (If
  stakeholders later prefer AND semantics for menus — "only show
  menus that contain gluten AND lactose" — that's a separate, larger
  scope change; out of scope here.)
- Exclude correctly retains menus whose dishes have no ingredients at
  all (the subquery yields no `id` row for those, so `where.not`
  keeps them).

### Controller: same pattern as ingredients

```ruby
# app/controllers/menus_controller.rb
def index
  @menus = Menu
    .search(params[:search])
    .with_restrictions(params[:include_restrictions])
    .without_restrictions(params[:exclude_restrictions])
    .order(name: :asc)
  @restrictions = Restriction.order(:name)
end
```

No new private methods, no new before_actions.

### View: drop in the same filter block

In `app/views/menus/index.html.erb`, replace the empty `<div></div>`
at line 22 with the same filter markup used by ingredients:

```erb
<div class="toolbar-filters">
  <span class="muted"><%= t("filters.dietary_restrictions") %>:</span>
  <% @restrictions.each do |restriction| %>
    <%= cycle_param_link(restriction.name,
          target: restriction.id,
          include_param: "include_restrictions",
          exclude_param: "exclude_restrictions",
          request: request) %>
  <% end %>
  <% if params[:include_restrictions].present? || params[:exclude_restrictions].present? %>
    <%= link_to t("filters.clear"),
          menus_path(request.query_parameters.except(:include_restrictions, :exclude_restrictions)),
          class: "chip-clear" %>
  <% end %>
</div>
```

Only the `link_to` "clear" target differs from the ingredients version
(it points to `menus_path` instead of `ingredients_path`).

**DRY check**: the filter block is now repeated in two views, modulo
the clear-link path. Reasonable options:

1. Leave it as two near-identical blocks — fine for two callers, both
   short.
2. Extract a `shared/_restriction_filters.html.erb` partial that takes
   the path helper or current resource as a local.

Recommendation: **option 1** for now. A partial becomes worth it if a
third view picks up the same filter, or if the block grows. Doing it
now would be a premature abstraction (per CLAUDE.md). Flag in the
follow-up section.

### i18n

Nothing new. Already in `ca.yml` / `en.yml`:

- `filters.dietary_restrictions`
- `filters.next_action.{neutral,exclude,include}`
- `filters.clear`

### CSS

Nothing new. The chip styling and the lighter-hover rules already
apply to any `.chip[data-state="…"]` regardless of which view renders
it.

### Fixtures

To exercise the new scopes we need richer test data. Plan to extend
existing fixture files (don't create parallel ones — additions only):

1. `test/fixtures/restrictions.yml` — add a `lactose` restriction so
   tests can cover multi-include cases independently of `gluten`.
2. `test/fixtures/ingredient_restrictions.yml` — add `milk_lactose`
   (the `milk` ingredient already exists per `dish_ingredients.yml`).
3. `test/fixtures/dish_ingredients.yml` — give one `tasting_menu`
   dish an ingredient that has no restrictions (so we can assert that
   a menu without any restricted ingredient survives a non-empty
   exclude filter, instead of getting an empty-set vacuous pass).

The exact ingredient choices to add will be confirmed during
implementation — depending on which existing ingredient fixtures
have no restriction, we may add one or two new ones.

### Tests

#### Menu model (`test/models/menu_test.rb`)

Add scope tests:

1. **`with_restrictions` returns menus that contain a matching
   ingredient**: passing `[gluten.id]` returns `weekly_menu` only.
2. **`with_restrictions` with empty / nil ids returns `all`** (matches
   the convention).
3. **`with_restrictions` is distinct**: a menu containing multiple
   gluten-bearing ingredients is returned once, not N times.
4. **`with_restrictions` with multiple ids ORs the match**: passing
   `[gluten.id, lactose.id]` returns any menu touching either.
5. **`without_restrictions` removes any menu touching the listed
   restrictions**: passing `[gluten.id]` excludes `weekly_menu`,
   keeps `tasting_menu`.
6. **`without_restrictions` keeps menus with no restricted
   ingredients at all** (the LEFT-join / NOT-IN edge case).
7. **`without_restrictions` with empty / nil ids returns `all`**.

#### Menus controller (`test/controllers/menus_controller_test.rb`)

Add filtering-aware integration tests:

1. **GET /menus filters by `include_restrictions[]`**: response body
   includes the matching menu name, does NOT include the
   non-matching one.
2. **GET /menus filters by `exclude_restrictions[]`**: complementary
   assertion.
3. **GET /menus with both params** applies both filters; URL state is
   reflected in the chips (assert that the rendered chip for the
   included restriction has `data-state="include"`).
4. **`@restrictions` is populated** so the toolbar renders something
   even when no filter is active.

No system tests (per CLAUDE.md project rules).

## Risks / things to confirm

- **Performance**: the include-scope join hits five tables. With the
  existing indexes this is fine for catalog-scale data, but we should
  eyeball the dev DB once. If a menu has thousands of dishes (it
  won't), we'd want `EXISTS` rewrite. Not now.
- **Multi-include semantics (OR vs AND)**: this plan commits to OR
  for parity with ingredients. If product disagrees, the change
  affects only the model scope (controller, view, helper, CSS are
  semantics-agnostic).
- **Partial extraction**: see DRY note above. A 3rd caller (or a 4th
  param) tips the balance toward partial.
- **`menu.dishes.count` N+1 in the view** is pre-existing
  (`menus/index.html.erb:37, 52`) and unrelated to this change.
  Flagging only — out of scope.

## Step-by-step execution

1. **Tests first** — write failing menu model scope tests and
   controller filter tests. Run, confirm red for the right reasons.
2. **Add the two scopes** to `Menu`. Tests should go green.
3. **Update `MenusController#index`** to chain the scopes and populate
   `@restrictions`. Controller tests should go green.
4. **Update the view** to render the filter row.
5. **Extend fixtures** (`restrictions.yml`,
   `ingredient_restrictions.yml`, possibly `dish_ingredients.yml`) as
   needed by the tests. Probably done together with step 1.
6. **Quality gate**: `bin/rails test`, `bin/rubocop`, `bin/brakeman`,
   `i18n-tasks health`.

## Out of scope

- A `MenuFilter` service object — the controller chain is two scopes;
  abstracting that is premature.
- Filtering the menu *show* page (only the index gets filters).
- Filtering by dish type, restaurant, validity, or any other field —
  this task is restriction-only.
- Refactoring `menu.dishes.count` to avoid N+1 (separate concern).
- Extracting a `shared/_restriction_filters` partial (deferred until
  there's a third caller).
