# Plan: Rename restriction type `religious` → `diet`

## Goal

Rename the `Restriction#restriction_type` enum value `religious` to `diet`. The
new bucket keeps the same meaning **plus** lifestyle/dietary patterns
(vegetarian, vegan, …). The semantic widening is the reason for the rename —
"religious" no longer accurately describes the bucket, which already contains
`Vegà` and `Vegetarià` in the seeds.

## Scope of the rename

Enum identifier only. The underlying integer (`1`) stays the same — no data
migration is required and the existing check constraint
(`restriction_type IN (0, 1)`) remains correct.

User-visible Catalan/English copy changes from "Religiosa / Religious" to
"Dieta / Diet" so the UI matches the broader meaning.

## Files to touch

### Model & data layer
- `app/models/restriction.rb` — enum `religious: 1` → `diet: 1`.
- `db/seeds.rb` — comment header `Religious Restrictions` → `Diet Restrictions`;
  local var `religious_restrictions` → `diet_restrictions`; assignment
  `r.restriction_type = :religious` → `:diet`.

### No DB migration
Integer mapping is unchanged, so no `ALTER TABLE` or check-constraint update is
needed. Fixtures store `restriction_type: 1` (integer) and remain valid.

### Tests
- `test/models/restriction_test.rb:17` — `:religious` → `:diet`.
- Run full suite; fixtures don't need edits (they use the integer `1`).

### Views
- `app/views/ingredients/_form.html.erb`
  - `group_labels` key `religious:` → `diet:`
  - second tuple element `"religious"` (the tag-kind CSS suffix) → `"diet"`
  - i18n key `ingredients.form.religious_restrictions` →
    `ingredients.form.diet_restrictions`
  - Update the DESIGN-GAP comment referencing `religious`.
- `app/views/restrictions/index.html.erb` — update DESIGN-GAP comment text
  (`religioses` mention, `religious` enum mention).
- `app/views/restrictions/_form.html.erb` — update DESIGN-GAP comment text.

### Helpers
- `app/helpers/serf_design_helper.rb:114` — `when "religious" then "religious"`
  becomes `when "diet" then "diet"`.

### CSS tokens & components
- `app/assets/stylesheets/serf_tokens.css`
  - `--tag-religious` → `--tag-diet`
  - `--tag-religious-soft` → `--tag-diet-soft`
- `app/assets/stylesheets/serf_components.css`
  - `.coverage-bar-fill-religious` → `.coverage-bar-fill-diet`
  - `.tag-religious` → `.tag-diet`
  - All `var(--tag-religious…)` references → `var(--tag-diet…)`

### i18n
- `config/locales/ca.yml`
  - `ingredients.form.religious_restrictions: Restriccions religioses` →
    `ingredients.form.diet_restrictions: Restriccions de dieta`
  - `restrictions.types.religious: Religiosa` →
    `restrictions.types.diet: Dieta`
- `config/locales/en.yml`
  - `ingredients.form.religious_restrictions: Religious restrictions` →
    `ingredients.form.diet_restrictions: Diet restrictions`
  - `restrictions.types.religious: Religious` →
    `restrictions.types.diet: Diet`

Verify alphabetical ordering of keys after edits; `i18n-tasks normalize` will
fix it if needed. Run `i18n-tasks health` to confirm no missing/unused keys.

## Verification steps

1. `bin/rails test` — full suite green.
2. `bin/rubocop` — zero offenses.
3. `i18n-tasks missing` and `i18n-tasks unused` — no findings related to the
   renamed keys.
4. Reset & reseed dev DB to make sure seeds still run:
   `bin/rails db:reset` (only if user agrees; otherwise document that a reseed
   is needed for the dev environment).
5. Manual grep for residual occurrences:
   `grep -rin "religious\|religio" app config db test`
   Expected result: no matches except possibly historical migration files
   (none exist for this enum), which we leave untouched.

## Order of execution

1. Model enum first (smallest blast radius; everything else depends on the new
   symbol name).
2. Helper + views + CSS tokens + locales (all consumer sites).
3. Seeds + tests + fixtures (data layer alignment).
4. Run test suite, rubocop, i18n-tasks. Iterate on any failure.
5. Final residual-occurrence grep.

## Out of scope

- Splitting the bucket into separate `religious` and `dietary` types.
- Adding the missing `preference` enum value flagged by existing DESIGN-GAP
  comments. Those comments will be updated only where they mention `religious`
  by name; the underlying gap remains for a future task.
- Reseeding production data (no production DB exists yet for this project).