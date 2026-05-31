# Code Review — US207-FrontRevision

**Branch:** `US207-FrontRevision`
**Base:** `develop` (already fully merged — merge-base == `develop` HEAD, `git merge develop` → "Already up to date")
**Reviewer:** automated rigorous review against `CLAUDE.md` / project standards
**Date:** 2026-05-31

## Scope

23 files changed (+919 / −211). Front-end revision: unified component styles, official brand
logo, waiter-facing dish cards with an interactive "alternatives" suggestion flow (Stimulus +
new `MenusController#alternatives` endpoint + `Dish#similar`), restriction tags surfaced across
list/show views, and a full seeds rewrite.

## Automated gates

| Gate | Result |
|---|---|
| `bin/rails test` | ✅ 256 runs, 655 assertions, 0 failures, 0 errors, 1 skip |
| `bin/rubocop` | ✅ 102 files, no offenses |
| `bin/brakeman` | ✅ 0 warnings |
| `i18n-tasks health` | ✅ no missing / no unused / normalized |

The gates are green, but several issues below are **not caught by the gates** (CSS is not linted,
JS is not tested, and the broken selectors still parse as valid CSS).

---

## Blocking issues

### 1. CSS typo breaks the coverage rail — `.serf-desgin`
`app/assets/stylesheets/serf_components.css:495`

```css
.serf-desgin .coverage-bar {   /* "desgin" — typo, should be "serf-design" */
```

The wrapper class on the page is `serf-design`, so this rule never matches. On top of the typo,
the rewrite **deleted** `.coverage-row` and `.coverage-head` and **dropped `height: 6px`** from
`.coverage-bar`. All three classes are still used in `app/views/menus/show.html.erb:88-94`, so the
restriction-coverage rail renders unstyled. This is a regression. Fix the selector name and restore
the removed rules.

### 2. Invalid CSS property — `-line-clamp`
`app/assets/stylesheets/serf_components.css:577`

```css
.serf-design .truncate-2 {
  display: -webkit-box;
  -line-clamp: 2;          /* was -webkit-line-clamp: 2; */
```

`-line-clamp` is not a real property. Multi-line truncation no longer works wherever `.truncate-2`
is used. Restore `-webkit-line-clamp: 2;` (keeping `line-clamp: 2;` alongside it is also fine).

### 3. Undefined grid class — `grid-8`
`app/views/restrictions/index.html.erb:32`

```erb
<div class="grid-8">   <!-- was: class="grid grid-4" -->
```

`.grid-8` is **not defined anywhere** in the stylesheets (only `.grid`, `.grid-2/3/4` exist). The
change also dropped the base `.grid` class, which is what supplies `display: grid`. Result: the
restrictions index loses its grid layout entirely. Either define `.grid-8` (with its responsive
breakpoints, matching the existing `.grid-N` pattern) or revert to an existing class.

---

## Non-blocking issues

### 4. Inline `<style>` block inside the brand SVG (logo)
`app/views/layouts/_sidebar.html.erb` and `app/views/layouts/login.html.erb`

The new official logo embeds a `<style>` element inside the inline SVG:

```html
<defs><style>.cls-1, .cls-2 { fill: var(--text-on-brand); }</style></defs>
```

This is not a `style="..."` attribute, so it does not technically violate the literal wording of
the "no inline styles" rule, but it embeds CSS in markup against the spirit of "CSS belongs in
stylesheets." Two further problems:

- **DRY:** the entire ~10-line SVG is duplicated verbatim in both layouts. It should be extracted
  into a shared partial (or added to the `serf_icon` helper) and the fill set via a CSS class
  rather than an inline `<style>`.

### 5. `Dish#similar` lives in the model, not a service object
`app/models/dish.rb`

`CLAUDE.md` states business logic — *"especially the suggestion engine"* — goes in `app/services/`.
`Dish#similar` is exactly the alternatives/suggestion engine. It currently sits on the model. Worth
relocating to a service object (e.g. `AlternativesService` / `SuggestionService`) for consistency
with the documented architecture. (The method itself was cleaned up in this review — see "Changes
applied".)

### 6. `set_menu` runs for `alternatives` but `@menu` is unused
`app/controllers/menus_controller.rb:2,51-57`

```ruby
before_action :set_menu, only: [ :destroy, :edit, :update, :show, :alternatives ]

def alternatives
  @dish = Dish.find(params[:dish_id])
  # ... @menu is never referenced
end
```

The action keys entirely off `params[:dish_id]` and ignores the loaded `@menu`. The member route
`get :alternatives, on: :member` forces a valid menu id into the URL purely to scope a dish-centric
lookup. It works, but the loaded `@menu` is dead and the route placement is semantically odd — an
alternatives lookup for a dish does not depend on the menu. Consider dropping `:alternatives` from
`set_menu`, and/or hanging the route off dishes instead of menus.

### 7. Heavy DRY duplication of the "restriction tags" block in views
`dishes/index` (×2), `dishes/show`, `ingredients/show`, `menus/index` (×2), `menus/_dish_card`
(×2), `menus/_alternatives_list`

The same pattern is repeated ~9 times:

```erb
<% restrictions = <source>.flat_map(&:restrictions).uniq %>
<% if restrictions.any? %>
  <div class="row ...">
    <% restrictions.each do |r| %>
      <span class="tag tag-<%= restriction_tag_kind(r) %>">...<%= r.name %></span>
    <% end %>
  </div>
<% end %>
```

`_dish_card` was correctly extracted, but the restriction-tags rendering was not. Given the explicit
DRY rule, extract a `_restriction_tags` partial (or a helper) taking the restriction collection.

### 8. N+1 queries in list views
`menus/index.html.erb:52,75`, `dishes/index.html.erb`, etc.

```erb
<% restrictions = menu.dishes.flat_map { |d| d.ingredients.flat_map(&:restrictions) }.uniq %>
```

On index pages this walks `dishes → ingredients → restrictions` per row with no eager loading.
The controllers should `includes(...)` the needed associations (the same fix applied to
`Dish#similar` in this review). Functional, but it will scale poorly.

### 9. Broad rescue that swallows seed errors
`db/seeds.rb` (ingredient-restriction loop)

```ruby
rescue => e
  puts "Error creating ingredient restriction: #{e.message}, ..."
```

Rescuing `StandardError` and printing means a genuine data mismatch (e.g. a renamed restriction)
fails silently and seeds "succeed" with missing associations. Prefer letting `find_by!` raise, or
narrow the rescue. (Note: the `Cacahuets` allergen/ingredient names were aligned in this rewrite, so
the previous mismatch is gone — the rescue is now masking nothing, which is exactly why it should be
removed.)

### 10. `test/fixtures/files/.keep` deleted
Harmless, but `.keep` exists to preserve the conventional empty fixtures dir in git. No reason to
remove it as part of this story.

---

## Test coverage assessment

- New controller tests (6) cover the `alternatives` happy path, auth redirect, and `not_found`.
  Good. But most assert only `assert_response :success` — the **filtering behaviour is not
  actually verified** (no assertion that an excluded restriction's dishes are absent / that a
  compatible alternative is present).
- **`Dish#similar` had no direct model unit test.** It is the core suggestion algorithm. This gap
  was closed in this review (see "Changes applied"): added 4 focused tests covering same-category
  filtering + self-exclusion, exclusion of dishes carrying an excluded restriction, ranking by
  shared-ingredient count, and the "top 3" cap.
- `menu_dish_card_controller.js` is untested — acceptable given the project's "no system tests"
  policy; the integration test confirms the markup renders.

---

## Answer: is `row_data_gateway_demo.rb` actually the Row Data Gateway pattern?

**Mostly yes, structurally — but it should not be in the repo at all.**

Against Fowler's definition (*PoEAA*: "an object that acts as a Gateway to a single record in a data
source; there is one instance per row"):

- ✅ **One instance per row** — `find` returns a single `new(attrs)`; `save`/`update`/`delete`
  operate on `@id`. This correctly distinguishes it from a *Table* Data Gateway (one instance for
  the whole table).
- ✅ **Encapsulated row CRUD** — `insert`, `update`, `delete` are the gateway operations; `find`/`all`
  are finders (placing finders as class methods on the gateway is an accepted RDG variant).
- ✅ **Thin data holder, minimal domain logic** — it leans RDG rather than Active Record (which would
  fold in domain behaviour).

Caveats:

- ⚠️ It is a **simulation**, not a real gateway: it backs onto an in-memory `@@data` array and only
  `puts` the SQL it *would* run. So it demonstrates the *shape* of the pattern without gatewaying to
  an actual data source.
- ⚠️ `tipus_nom` / `tipus_display` introduce presentation/domain mapping that a purist RDG would keep
  out of the gateway — a minor blur toward Active Record.

**Verdict on keeping it:** regardless of pattern correctness, this file violates project conventions
and should be **deleted** (or moved into `doc/` if it must be kept as teaching material):

- It is a standalone PoC at the **project root** — `CLAUDE.md` requires all docs under `doc/`, and
  forbids dead/unused files. Rails never loads it; it is orphaned.
- It runs a `puts`-driven demo at file scope and contains Spanish/Catalan comments (code/comments
  should be English).

---

## Changes applied in this review

- **`app/models/dish.rb` — `Dish#similar` refactor** (per request):
  1. Added explanatory comments for each step.
  2. Eager-loaded `includes(ingredients: :restrictions)` to remove the N+1 — query count is now a
     fixed cost rather than growing per candidate (measured via a `sql.active_record` subscriber;
     this confirms N+1 removal, not output correctness — correctness is locked by the new tests).
  3. Rewrote the YARD doc with concrete return type `@return [Array<Dish>]` (kept
     `@param ... [Enumerable<Restriction>]` since any enumerable is accepted), fixed the typo
     ("disher"), and clarified ordering. Also compares by restriction/ingredient **id** (via `Set`)
     instead of relying on `Array#&` over AR objects.

- **`test/models/dish_test.rb`** — added 4 unit tests for `Dish#similar` (same-type filtering +
  self-exclusion, excluded-restriction filtering, shared-ingredient ranking, top-3 cap).

- **`app/views/menus/_dish_card.html.erb` — unified card for all roles.** Removed the
  `current_user.waiter?` fork; every role now sees the same interactive card (toggleable restriction
  tags + alternatives flow). Made the whole card navigate to the dish via an accessible
  "stretched link" (a single empty `<a>` overlaying the row) so the real link semantics are kept
  (keyboard, middle-click, open-in-new-tab) while the tags remain clickable above it. Added the
  generic `.stretched-link` utility and `position`/`z-index` on `.menu-dish-row` /
  `.restriction-toggle`. Integration tests updated to assert the unified card for waiter, kitchen
  manager and admin.

  Full suite: **258 runs, 701 assertions, 0 failures, 1 skip**. RuboCop and Brakeman clean.

## Recommendation

Address blocking issues **#1–#3** (broken CSS — they ship visibly broken UI) before merge. **#4–#10**
and the test-coverage gaps (especially a unit test for `Dish#similar`) should be follow-ups. Delete
`row_data_gateway_demo.rb`.

---

## Resolution — all findings fixed in the follow-up commit

| # | Finding | Fix |
|---|---|---|
| 1 | `.serf-desgin` typo / deleted coverage classes | Fixed selector; restored `.coverage-row`, `.coverage-head`, and `.coverage-bar { height: 6px }`. |
| 2 | `-line-clamp` invalid | Restored `-webkit-line-clamp: 2` (+ standard `line-clamp: 2`). |
| 3 | undefined `grid-8` | Defined `.grid-8` with responsive breakpoints (8→4→2); view back to `grid grid-8`. |
| 4 | logo `<style>` + duplication | Extracted `layouts/_brand_logo` partial; fill via `.serf-logo` CSS rule (covers both `.serf-design` layouts). |
| 5 | suggestion engine on model | Moved to `app/services/suggestion_service.rb`; `Dish#similar` removed; tests moved to `test/services/`. |
| 6 | unused `@menu` in `alternatives` | Dropped `:alternatives` from `set_menu`; controller calls `SuggestionService`. |
| 7 | duplicated restriction-tags block | Extracted `shared/_restriction_tags` (locals: `restrictions`, `wrapper_class`, `dot`); replaced 7 sites. Markup verified byte-identical. |
| 8 | N+1 in list views | Added `includes(...)` in `menus#index`, `dishes#index`, and `ingredients#show`. |
| 9 | broad rescue in seeds | `begin/rescue` removed; `find_by!` raises. |
| 10 | `test/fixtures/files/.keep` deleted | Restored. |
| — | `row_data_gateway_demo.rb` | Deleted (orphaned root-level PoC). |
| 11 | restrictions index dumped the raw `types` hash on a phantom third card | Root cause: stale rows with the removed third `restriction_type` (2) — read by the enum as `nil` — plus DB drift (the live check constraint was `IN (0,1,2)`, not `IN (0,1)`). Migration `ConsolidateRestrictionTypes` re-maps type 2 → diet (1) and tightens the constraint to `IN (0,1)`. (Run `bin/rails db:migrate`.) |

After fixes: **258 runs, 701 assertions, 0 failures, 1 skip**; RuboCop and Brakeman clean; i18n
healthy.
