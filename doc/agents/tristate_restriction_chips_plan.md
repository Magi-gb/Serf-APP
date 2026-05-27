# Tri-state restriction filter chips — implementation plan

## Goal

Collapse the two parallel chip rows ("Inclou" / "Exclou") on
`app/views/ingredients/index.html.erb` into a single row of chips that
cycle through three states on click:

1. **Neutral** (default) — restriction is not filtered.
2. **Exclude** (red) — hide ingredients with this restriction.
3. **Include** (green) — only show ingredients with this restriction.
4. Next click from Include returns to Neutral.

Rationale: excluding a restriction is far more common than including
one (typical use case is "hide things this diner can't eat"), so the
single-click default is Exclude. Include is reachable in two clicks.

This is a UI-only change. The URL contract
(`include_restrictions[]` + `exclude_restrictions[]`) and the
controller scopes (`with_restrictions` / `without_restrictions`) stay
exactly as they are today.

## Current state (verified)

- `app/views/ingredients/index.html.erb:18-45` renders two
  `@restrictions.each` loops, each calling `toggle_param_link` with
  `mode: :include` or `mode: :exclude`.
- `app/helpers/serf_design_helper.rb:182-204` defines
  `toggle_param_link(label, mode:, target:, include_param:,
  exclude_param:, request:, css:)`. The helper already enforces mutual
  exclusion: activating `mode: :include` for an id removes that id
  from the exclude list, and vice versa.
- `app/controllers/ingredients_controller.rb:8-9` reads
  `params[:include_restrictions]` and `params[:exclude_restrictions]`
  independently. **No controller changes needed.**
- CSS for the active states lives at
  `app/assets/stylesheets/serf_components.css:257-266`, keyed on
  `.chip[data-mode="…"][aria-pressed="true"]`.
- `config/locales/ca.yml:93-96` has `filters.clear`, `filters.exclude`,
  `filters.include`.
- `toggle_param_link` has **one** caller (the ingredients index). No
  other view depends on it.
- No existing helper tests under `test/helpers/`.

## Design

### Helper: replace, don't extend

Replace `toggle_param_link` with a single `cycle_param_link`. Keeping
both helpers would violate the CLAUDE.md rule against speculative
abstraction — the old helper has no remaining caller.

```ruby
# app/helpers/serf_design_helper.rb
#
# Build a link that cycles a value through three states inside a pair
# of array params: neutral → exclude → include → neutral.
# Used by the ingredients filter chips.
def cycle_param_link(label, target:, include_param:, exclude_param:, request:)
  target = target.to_s
  include_ids = Array(request.query_parameters[include_param]).map(&:to_s)
  exclude_ids = Array(request.query_parameters[exclude_param]).map(&:to_s)

  # `current_state` reflects which list `target` is currently in.
  # The URL we build is the NEXT state the chip transitions to on click.
  current_state, new_include, new_exclude =
    if include_ids.include?(target)
      # current: include → next click: neutral
      [ "include", include_ids - [ target ], exclude_ids              ]
    elsif exclude_ids.include?(target)
      # current: exclude → next click: include
      [ "exclude", include_ids + [ target ], exclude_ids - [ target ] ]
    else
      # current: neutral → next click: exclude
      [ nil,       include_ids,              exclude_ids + [ target ] ]
    end

  new_params = request.query_parameters.except(include_param, exclude_param)
  new_params[include_param] = new_include if new_include.any?
  new_params[exclude_param] = new_exclude if new_exclude.any?
  path = new_params.empty? ? request.path : "#{request.path}?#{new_params.to_query}"

  link_to(
    label,
    path,
    class: [ "chip", ("chip-#{current_state}" if current_state) ].compact,
    "data-state": current_state,
    title: t("filters.next_action.#{current_state || 'neutral'}")
  )
end
```

Notes:

- The helper computes both `current_state` (for CSS / a11y) and the
  next-state URL in the same call. The variable named `state` in the
  first `if` block is intermediate — see the actual `current_state`
  derivation immediately below.
- `aria-pressed` is dropped: it is a binary attribute and does not
  model three states. `data-state` drives CSS; `title` gives the
  hover hint describing what the next click will do; the visible
  label remains the restriction name.
- Mutual exclusion is now implicit in the state machine rather than an
  ad-hoc "also remove from the other list" line — same outcome.

### View

```erb
<%# app/views/ingredients/index.html.erb — toolbar block %>
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
          ingredients_path(request.query_parameters.except(:include_restrictions, :exclude_restrictions)),
          class: "chip-clear" %>
  <% end %>
</div>
```

The `toolbar-sep` span and the second `@restrictions.each` loop are
gone. The `t("filters.include")` / `t("filters.exclude")` row labels
are replaced by a single `t("filters.dietary_restrictions")` legend.

### CSS

Replace the two selectors at
`app/assets/stylesheets/serf_components.css:257-266` with:

```css
.serf-design .chip[data-state="include"] {
  background: var(--accent-green);
  border-color: var(--accent-green);
  color: var(--surface-raised);
}
.serf-design .chip[data-state="exclude"] {
  background: var(--brand-red);
  border-color: var(--brand-red);
  color: var(--text-on-brand);
}
```

Same colors — only the attribute used in the selector changes. The
generic `chip[aria-pressed="true"]` rule at
`serf_components.css:880-884` stays untouched (it serves other chips).

### i18n (`config/locales/ca.yml`)

Add under `filters:`:

```yaml
filters:
  clear: Esborra filtres
  dietary_restrictions: Restriccions
  next_action:
    neutral: "Clic per excloure"
    exclude: "Clic per incloure"
    include: "Clic per esborrar el filtre"
```

Drop `filters.include` and `filters.exclude` — no remaining callers
after the view change. Run `i18n-tasks unused` to confirm.

### Tests

Add `test/helpers/serf_design_helper_test.rb` (new file) covering
`cycle_param_link`:

1. **Neutral → exclude**: id absent from both params produces a URL
   with the id added to `exclude_restrictions`.
2. **Exclude → include**: id in `exclude_restrictions` produces a URL
   that removes it from exclude and adds it to include.
3. **Include → neutral**: id in `include_restrictions` produces a URL
   that removes it from both, and when both lists end up empty the
   URL has no query string (matches the `empty? ? request.path`
   branch).
4. **Other query params preserved** (e.g. `search`, `view`): cycle a
   restriction while `?search=foo&view=grid` is set — those keys must
   survive on the resulting URL.
5. **Rendered chip carries the right `data-state` and `title`** for
   each of the three current states.

Use `ActionController::TestRequest` to build the `request` argument
(see `ActionDispatch::TestRequest.create` pattern). The helper does
not need any model fixtures.

The existing ingredients controller tests already exercise filter
scoping by setting the params directly, so no controller test changes
are required. After the refactor, run `bin/rails test` to confirm
nothing regressed (in particular the existing functional test for
`ingredients#index` filtering).

## Out of scope

- No change to dishes filtering (different feature, different view).
- No Stimulus controller / no client-side state — Turbo Drive
  navigation continues to drive the cycle, same as today.
- No new "Only mine" / "Reset all" affordances beyond the existing
  `chip-clear` link.

## Step-by-step execution

1. Update `config/locales/ca.yml`: add the new keys, remove the two
   obsolete ones. Run `i18n-tasks normalize`.
2. Replace `toggle_param_link` with `cycle_param_link` in
   `app/helpers/serf_design_helper.rb`. Update the doc comment.
3. Update `app/views/ingredients/index.html.erb`: single loop, new
   legend, drop the separator span.
4. Update the two CSS selectors at `serf_components.css:257-266` to
   key off `data-state` instead of `data-mode` + `aria-pressed`.
5. Add `test/helpers/serf_design_helper_test.rb` with the five cases
   above. Verify failing → make passing.
6. Run `bin/rails test`, `bin/rubocop`, `bin/brakeman`,
   `i18n-tasks health`.
7. Manually exercise the page (three clicks on a chip) once during
   review — covered by the test suite functionally, but the visual
   transition is worth eyeballing once.

## Risks / things to confirm during implementation

- **Tooltip wording in Catalan** — the strings above are a first cut;
  worth a quick review with the team's existing UI copy.
- **Color-only state communication** — green/red plus a tooltip is OK
  for sighted users but limits accessibility for users who can't see
  the color or use the tooltip. If we decide this is a concern, add a
  small inline icon (e.g. `+` / `−`) next to the label per state.
  Not in scope for the first pass; flagged for review.
- **`title` vs proper tooltip** — `title` works but is not
  keyboard-accessible on all browsers. Acceptable for an MVP; revisit
  if accessibility audit flags it.
