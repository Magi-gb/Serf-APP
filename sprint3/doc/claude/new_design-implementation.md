# SerF — Refined Design implementation notes

**Branch:** `new_design`
**Source:** Claude Design handoff bundle (2026-05-11), file `SerF - Refined Design.html`
**Date:** 2026-05-11

This document records (1) what was implemented from the design, (2) why we chose
**ERB partials** instead of ViewComponent, (3) gaps where the design assumes
model fields, tables or services we don't have yet.

---

## 1 · Component pattern decision: ERB partials (not ViewComponent)

The design system has a small, simple set of reusable pieces: button, card,
avatar, tag, restriction bubble, chip, stat tile, sidebar, topbar. None of them
need slots, complex parameterisation or per-component testing in isolation
(yet). For that scope:

| Concern | Partials | ViewComponent |
|---|---|---|
| Dependency | None (Rails-native) | Adds `view_component` gem |
| Learning curve | Zero | Class-per-component, slots API |
| Performance | OK; modest overhead per render | Faster (compiled to method calls) |
| Encapsulation | Loose; locals are untyped | Strict initializer, raises on missing args |
| Testability | Indirect (controller tests) | Each component testable in isolation |

For a university project where the team is still learning Rails and the design
is mostly layout-and-CSS, **partials win on simplicity**. If components grow to
need slots, conditional rendering branches, or per-component tests, migrate the
hot ones to ViewComponent then — not preemptively.

Where partials/helpers live in this branch:

- `app/views/layouts/_sidebar.html.erb` — the refined sidebar
- `app/views/shared/_topbar.html.erb` — title + subtitle + actions block
- `app/views/shared/_form_errors.html.erb` — form error list
- `app/helpers/serf_design_helper.rb`
  - `serf_icon(:home)` — Lucide-style outline SVG icons (only-in-design ones)
  - `serf_btn(...)` — primary/secondary/ghost/danger button (kept simple for now)
  - `restriction_tag_kind(r)` — maps the `restriction_type` enum to a CSS tag class

---

## 2 · CSS organisation

Three new files. Tokens load before everything so the `--var` cascade is intact.

```
app/assets/stylesheets/
├── application.css            # Manifest (explicit order)
├── serf_tokens.css            # Design tokens (colours, type, spacing, radii…)
├── serf_components.css        # Components (buttons, cards, sidebar, login…)
├── login.css                  # Legacy (still loaded; some old screens use it)
└── style_definition.css       # Legacy (still loaded; some old screens use it)
```

All new component rules are scoped under `body.serf-design` so the legacy CSS
keeps working on any view not yet migrated.

To activate the new design on any page, the layout sets `<body class="serf-design">`.

---

## 3 · Views migrated to the new design

| View | Status | Notes |
|---|---|---|
| `layouts/application` | ✅ | New body class, app-shell grid, refined sidebar, flash notices use `.notice` |
| `layouts/_sidebar` | ✅ | Icons + collapsible-via-media-query, emergency button, user box with logout |
| `layouts/login` | ✅ | Two-column brand-left / form-right with Inter font |
| `devise/sessions/new` | ✅ | Refined sign-in form with Inter labels |
| `home/index` (dashboard) | ⚠ partial | KPI tiles + quick-access grid + activity placeholder (see gap §A) |
| `ingredients/{index,show,new,edit,_form}` | ✅ | List card, restriction tags, fieldset-based restriction picker |
| `dishes/{index,show,new,edit,_form}` | ⚠ partial | Card grid (see gaps §B, §D) |
| `menus/{index,show,new,edit,_form}` | ⚠ partial | Flat list with per-type grouping (see gap §C) |
| `restrictions/{index,show,new,edit,_form}` | ⚠ partial | Grouped by `restriction_type` (see gap §E) |
| `protocols/{index,show,new,edit,_form}` | ✅ | List card, detail view |
| `users/{index,show,new,edit,_form}` | ⚠ partial | Basic forms (see gap §F) |
| `profiles/{show,edit}` | ❌ not yet | Still uses legacy CSS; see TODO §G |

All migrated views use the new component classes (`.btn`, `.card`, `.tag`, etc.) and the `.topbar` + `.content` layout pattern.

---

## 4 · Gaps — design features that need model/feature work

Each gap is also annotated **inline in the views** with a `DESIGN-GAP:` comment
so it surfaces during code review. The full list:

### §A — Dashboard activity feed and per-period KPI trends
The design shows:
- **Recent activity** (who did what, when) — needs an `Activity` model or
  `paper_trail` gem.
- **KPI trend lines** (`+6 aquest mes`, `2 nous aquest mes`, `3 esborranys`) —
  needs `created_at` scopes + a `published/draft` state on Menu.

What's there: counts only (`Dish.count`, `Menu.count`, etc.) and a "no
activity recorded yet" placeholder.

### §B — Dish images and price
- `Dish` has no `image_url`/attachment → grid uses a textured placeholder with
  the first 2 chars of the dish name as a stamp.
- `Dish` has no `price` → the meta row in the dish card only shows the
  `dish_type`.

### §C — Menu structure: sections, type, validity, state, restaurant
The design proposes:
- **Menu sections** (Entrants / Primers / …) with order and a builder UI.
- **Menu type** (Carta / Menú del dia / Menú de grup / Menú estacional).
- **Validity dates** (`starts_on`, `ends_on`) — **removed** by migration
  `20260502122822_simplify_menus.rb`; the old `MenuDatesValidator` was deleted
  during the CRUD-de-Menú review.
- **State** (`draft` / `published` / `archived`).
- **Restaurant** assignment (Cal Blay has multiple sites).
- **Coverage indicators** for common restrictions (sense gluten / lactosa /
  vegà…) — depends on the SuggestionService.
- **Per-dish price** inline in the menu.
- **Drag-and-drop** ordering.

What's there: a flat checkbox list of dishes grouped by `dish_type`.

### §D — DishIngredient `essential` flag (and the SuggestionService)
CLAUDE.md plans `DishIngredient` to have an `essential` boolean. Without it:
- The dish detail can't classify ingredients into "imprescindibles" vs
  "substituïbles" (the design renders them with a red/green sidebar).
- The dish card on the cambrer screen can't show ok/warn/block status.
- There is no `SuggestionService` yet to compute compatibility for a given
  set of restrictions.

Implementing `essential` is a one-column migration + a UI change in the dish
form; the SuggestionService is a separate task.

### §E — Restriction extra fields
The design references:
- **`code`** (short, monospace, max 6 chars) for posters & quick references.
- **`severity`** chip (low/medium/high) with anaphylaxis warning colour.
- **`visible_to_waiter`** boolean toggle.
- **`efsa_official`** boolean to flag EU Annex II allergens.
- A **4th `preference` enum value** to round out al·lèrgens / intoleràncies /
  religioses / preferències. Currently only `intolerance_allergy` and
  `religious` exist.

### §F — User extended fields
- Email, restaurant assignment, avatar colour preference, internal notes,
  active toggle, last-login timestamp.
- The design has 4 role cards (Administradora / Cap de cuina / Personal de
  cuina / Cambrera). We have 3 (`admin` / `kitchen_manager` / `waiter`).
  Adding a `kitchen_staff` role is a one-line enum change but affects
  authorization rules in `Authorizable`.

### §G — Profile / password change page
The design includes a dedicated **password change** screen with a strength
meter and live-validated requirement checklist (8+ chars, mix of cases,
digit, symbol). Devise's `DatabaseAuthenticatable` provides the backend, but
the UI hasn't been rebuilt — `profiles/show` and `profiles/edit` still use
the legacy `page-card` / `.btn-primary` classes.

### §H — Cambrer (waiter) filtering flow
The design ships:
- A **PDA-first screen** (360×640) for one-handed use: chip filters, status
  badges per dish, bottom action bar.
- A **tablet/desktop equivalent** with tabs Compatibles / Substituïbles / No
  compatibles and a dish detail with substitution suggestions.

None of this exists yet because the **filtering engine (`SuggestionService`)**
isn't implemented. CLAUDE.md plans it as the next big piece.

### §I — Restrictions catalogue extras
- Per-restriction badge with EFSA Annex II marker.
- Live preview (in the form) of how the restriction will appear on the
  cambrer view.
- "Plats afectats" list with sub / no-sub status (depends on §D).

### §J — Responsive / mobile artboards
The design has tablet (820×1180) and mobile (390×844) artboards for the
critical waiter flow + admin dashboard. Our CSS includes the breakpoint rules
to **collapse the sidebar to icons at ≤1024 px** and **hide it entirely with a
single-column layout at ≤640 px**, but the mobile-first cambrer flow itself
(bottom nav, sticky action bar) isn't built — same dependency as §H.

### §K — Tweaks panel (theme/density/palette)
The design canvas has a tweaks panel with theme (light/dark), density
(comfortable/compact) and palette variants. The CSS variables for all of
them are already in `serf_tokens.css` (`[data-theme="dark"]`,
`[data-density="compact"]`). To activate, set the attributes on `<body>` — a
small Stimulus controller would be enough. Not yet wired up.

### §L — Emergency phone link
The sidebar's "Emergències · 112" currently uses `tel:112`. The design's
intent was probably to deep-link to an emergency protocol; we'd need an
`emergency` flag on `Protocol` (or a designated record) for that.

### §M — Activity log / audit trail
References to "última edició per X" / "creat per X" across the design. Not
backed by any data; would need PaperTrail or an in-house `Activity` model.

---

## 5 · Quality checks (status at last run)

- ✅ Tests: 186/186 passing (1 expected skip)
- ✅ RuboCop: 0 offenses
- ✅ Brakeman: 0 warnings
- ✅ i18n-tasks `missing`: clean
- ✅ i18n-tasks `check-normalized`: clean

---

## 6 · What to do next (suggested order)

1. **Add `DishIngredient#essential`** — one migration, unlocks §D, §I.
2. **Wire the dark mode / density tweaks** — pure Stimulus + CSS, no model
   change. Cheap win for §K.
3. **Build the `SuggestionService`** and the cambrer filter screen — unlocks
   §H and most of §J.
4. **Extend Menu**: add `description`, `published_at`, `archived_at`,
   sections (or section type enum). Unlocks §C.
5. **Restriction extras**: `code`, `severity`, `efsa_official`. Unlocks §E.
6. **User extras** (email, site, notes, last_seen). Unlocks §F.
7. **Migrate `profiles/{show,edit}`** to the new design (small, cosmetic).
8. **Activity log** — last because it's expensive (PaperTrail or custom). §A, §M.
