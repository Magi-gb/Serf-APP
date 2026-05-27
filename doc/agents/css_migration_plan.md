# Plan: Migrate old CSS to style_definition.css

## Context

The project has two CSS systems: the old BEM-style classes in `app/assets/stylesheets/old/` (layout.css, login.css, users.css) and the newer design system in `style_definition.css`. The goal is to consolidate everything into `style_definition.css` (expanded with missing sections) + a separate `login.css` for login-only styles, then update all views to use the new class names, and delete the `old/` directory.

Sprockets uses `require_tree` so all CSS files are bundled together. No tests reference CSS classes, so renaming is safe.

### Naming conventions (agreed)

- **Flat hyphenated names** — no BEM (`__`, `--`). Consistent with existing style_definition.css and visual_tests page.
- **Semantic button names** — `btn-primary`, `btn-danger`, etc. (not visual names like `btn-yellow-small`). Renaming existing buttons too.
- **Alert prefix** — `alert-error`, `alert-success`, `alert-info`, `alert-warning` for block-level notifications.
- **Field error** — rename existing `.error` → `.field-error` for inline input error tooltips. Keep `input-error` as the input state class.
- **Component prefixes** — `list-card-*`, `detail-*`, `field-*` to group related classes.

---

## Step 1: Expand and refactor `style_definition.css`

### 1a. Base elements — add `label` and `select` styling
- `label`: block display, font-weight 600, margin-bottom
- `select`: match input styling (padding, border, font)

### 1b. Utility classes

**Spacing** (margin & padding, 0–5 scale: 0 / 0.25rem / 0.5rem / 1rem / 1.5rem / 3rem):
- `.m-{0-5}`, `.mt-{0-5}`, `.mr-{0-5}`, `.mb-{0-5}`, `.ml-{0-5}`, `.mx-{0-5}`, `.my-{0-5}`
- `.p-{0-5}`, `.pt-{0-5}`, `.pr-{0-5}`, `.pb-{0-5}`, `.pl-{0-5}`, `.px-{0-5}`, `.py-{0-5}`

**Text alignment:**
- `.text-left`, `.text-center`, `.text-right`

**Flex:**
- `.d-flex`, `.flex-column`, `.flex-row`, `.flex-wrap`
- `.align-items-center`, `.align-items-start`, `.align-items-end`
- `.justify-content-center`, `.justify-content-between`, `.justify-content-end`
- `.flex-1`, `.flex-shrink-0`
- `.gap-{0-5}` (same scale as spacing)

### 1c. Buttons — rename to semantic + add `btn-danger`

Rename existing buttons:
- `btn-yellow-big` → `btn-primary-big`
- `btn-yellow-small` → `btn-primary`
- `btn-white` → `btn-secondary`

Add new:
- `btn-danger` — red bg (`var(--color-accent-red)`), white text, same structure as `btn-primary`

Hover states:
- `btn-primary-big`, `btn-primary`: scale(1.05) + darken yellow
- `btn-secondary`: scale(1.05) + darken white
- `btn-danger`: scale(1.05) + darken red (#c41e28)

### 1d. Alerts — block-level notifications (new section)

Four variants, all sharing the same base structure (padding, border-radius, font-size, font-weight, display: block):
- `.alert-error` — dark red bg (#9b101b), white text
- `.alert-success` — green bg (#2d7a3a), white text
- `.alert-info` — blue bg (`var(--color-accent-blue)`), white text
- `.alert-warning` — yellow bg (`var(--color-accent-yellow)`), dark text

No `::before` arrow on alerts (that's for `.field-error` only).

### 1e. Field errors — rename existing `.error`

- Rename `.error` → `.field-error` (inline tooltip with `::before` arrow, positioned below input)
- Keep `input-error` as-is (input state class for red border)

### 1f. Navigation — expand `.sidenav` with footer/logout/active

Add to existing sidenav section:
```css
.sidenav-active a {
    background-color: var(--color-bg);
    color: var(--color-accent-red);
    font-weight: bold;
}

.sidenav-footer {
    margin-top: auto;
    border-top: 1px solid rgba(255, 255, 255, 0.2);
    padding: 0.5rem 0;
}

.sidenav-logout a {
    color: #ffcccc;
}

.sidenav-logout a:hover {
    background-color: rgba(255, 0, 0, 0.15);
    color: #ffcccc;
}
```

### 1g. Forms — new section

Migrated from old/users.css, adapted to use CSS vars:
- `.form-container` — max-width: 450px (NOT `.container`, which is a layout class)
- `.form-group` — margin-bottom: 1.2rem
- `.form-hint` — font-size: 0.85rem, muted color, margin-top: 0.2rem
- `.form-actions` — margin-top: 1.5rem

Form errors summary uses `.alert-error` with a `<ul>` inside (no separate `.form-errors` class needed).

### 1h. Lists & detail patterns — new section

Generic reusable patterns (migrated from old/users.css):
- `.list-card-group` — flex column with gap (replaces `.users-list`)
- `.list-card` — flex row, `var(--color-bg)` bg, border-radius: 10px, hover shadow (replaces `.user-card`)
- `.list-card-avatar` — 44px circle, centered text, flex-shrink: 0 (replaces `.user-card__avatar`)
- `.list-card-info` — flex column (replaces `.user-card__info`)
- `.list-card-title` — font-weight: 700, 1rem (replaces `.user-card__username`)
- `.list-card-subtitle` — font-size: 0.85rem, muted color (replaces `.user-card__role`)
- `.detail-section` — centered flex column, padding (replaces `.user-detail`)
- `.detail-avatar` — 80px circle, centered text, margin-bottom (replaces `.user-detail__avatar`)
- `.detail-actions` — flex row with gap: 1rem (replaces `.user-detail__actions`)
- `.field-group` — margin-bottom: 1rem (replaces `.profile-field`)
- `.field-label` — font-weight: 600, muted color, font-size: 0.85rem (replaces `.profile-field__label`)
- `.field-value` — font-size: 1.1rem (replaces `.profile-field__value`)
- `.empty-state` — muted color, italic (replaces `.users-empty`)

---

## Step 2: Create `login.css` (not in old/)

Move login-specific styles from `old/login.css` to `app/assets/stylesheets/login.css`:
- `.login-page`, `.login-stripes`, `.login-stripe-yellow`, `.login-stripe-blue` (drop `--` for consistency with flat naming)
- `.login-container`, `.login-card`, `.login-card-title` (drop `__`)
- `.login-flash`, `.login-flash-alert` (drop `__`)
- `.login-form`, `.login-form-input` (drop `__`)

Changes from old version:
- Remove `.login-form__submit` (replaced by `.btn-primary-big`)
- Remove global `input { width: 21vw; }` (conflicts with global input styling)
- Rename classes to flat naming (no `--` or `__`)

---

## Step 3: Update views

### `layouts/application.html.erb`
- `body class="app-body"` → `body class="layout-with-sidebar"`
- `main class="main-content"` → `main class="page-content-with-sidebar"`
- `div class="flash flash--notice"` → `div class="alert-success"`
- `div class="flash flash--alert"` → `div class="alert-error"`

### `layouts/_sidebar.html.erb`
- `nav class="sidebar"` → `<ul class="sidenav">`
- Remove `sidebar__brand` div (logo now in sidenav background-image)
- Remove `sidebar__logo` image tag
- `ul class="sidebar__menu"` → items directly inside `<ul class="sidenav">`
- `sidebar__item` → `<li>` (no class needed)
- `sidebar__item--active` → `<li class="sidenav-active">`
- `sidebar__link` → no class needed (`.sidenav li a` handles it)
- `sidebar__footer` → `<li class="sidenav-footer sidenav-logout">`
- `sidebar__link--logout` → no extra class (`.sidenav-logout a` handles it)

### `layouts/login.html.erb`
- `login-stripes` → `login-stripes` (kept)
- `login-stripe--yellow` → `login-stripe-yellow`
- `login-stripe--blue` → `login-stripe-blue`
- `login-flash` → `login-flash` (kept)
- `login-flash__alert` → `login-flash-alert`

### `devise/sessions/new.html.erb`
- `login-card__title` → `login-card-title`
- `login-form__input` → `login-form-input`
- `login-form__submit` → `btn-primary-big`

### `users/index.html.erb`
- `users-header` → `page-header`
- `users-search` → `mb-3`
- `search-form__input` → remove class (global `input` styling)
- `users-list` → `list-card-group`
- `user-card` → `list-card`
- `user-card__avatar` → `list-card-avatar`
- `user-card__info` → `list-card-info`
- `user-card__username` → `list-card-title`
- `user-card__role` → `list-card-subtitle`
- `users-empty` → `empty-state`
- `users-actions` → `mt-2`
- `btn btn--primary` → `btn-primary`

### `users/show.html.erb`
- `user-detail` → `detail-section`
- `user-detail__avatar` → `detail-avatar`
- `user-detail__username` → remove class (global `<h1>` styling)
- `user-detail__role` → `list-card-subtitle`
- `user-detail__actions` → `detail-actions`
- `btn btn--primary` → `btn-primary`
- `btn btn--danger` → `btn-danger`

### `users/_form.html.erb`
- `user-form` → `form-container`
- `form-errors` → `alert-error`
- `form-group` → `form-group` (kept, now in style_definition)
- `form-label` → remove class (global `label` styling)
- `form-input` → remove class (global `input` styling)
- `form-hint` → `form-hint` (kept, now in style_definition)
- `form-actions` → `form-actions` (kept, now in style_definition)
- `btn btn--primary` → `btn-primary`

### `profiles/show.html.erb`
- `profile-card` → `card`
- `profile-field` → `field-group`
- `profile-field__label` → `field-label`
- `profile-field__value` → `field-value`
- `profile-actions` → `mt-4`
- `btn btn--primary` → `btn-primary`

### `profiles/edit.html.erb`
- `password-form` → `form-container`
- `user-form` → remove (parent already has `form-container`)
- `form-errors` → `alert-error`
- `form-group` → `form-group` (kept)
- `form-label` → remove class (global `label`)
- `form-input` → remove class (global `input`)
- `form-actions` → `form-actions` (kept)
- `btn btn--primary` → `btn-primary`

---

## Step 4: Update `public/visual_tests/index.html`

Update class names to match the new naming:
- `btn-yellow-big` → `btn-primary-big`
- `btn-yellow-small` → `btn-primary`
- `btn-white` → `btn-secondary`
- `.error` → `.field-error`
- Add new sections to demonstrate: `btn-danger`, alerts (`alert-error`, `alert-success`, `alert-info`, `alert-warning`), list-card components, detail-section, field-group/field-label/field-value, form components

---

## Step 5: Delete `old/` directory

Remove:
- `app/assets/stylesheets/old/layout.css`
- `app/assets/stylesheets/old/login.css`
- `app/assets/stylesheets/old/users.css`

---

## Step 6: Verify

1. `bin/rails server` — manually check:
   - Login page renders correctly (stripes, card, flash)
   - After login, sidebar renders with logo, menu items, active state, logout
   - Users index: search bar, card list, new user button
   - User show: avatar, detail section, edit/delete buttons
   - User form: labels, inputs, hints, error display, submit
   - Profile show: field labels/values, change password button
   - Profile edit: password form, errors, submit
2. Open `http://localhost:3000/visual_tests/index.html` — check all components render
3. `bin/rails test` — all 22 tests pass (no CSS class references in tests)
4. `bin/rubocop` — no offenses
5. `bin/brakeman` — no warnings

---

## Files to modify

| File | Action |
|---|---|
| `app/assets/stylesheets/style_definition.css` | Expand with sections 1a-1h, rename buttons, rename .error |
| `app/assets/stylesheets/login.css` | Create (move + adapt from old/login.css) |
| `app/views/layouts/application.html.erb` | Update classes |
| `app/views/layouts/_sidebar.html.erb` | Restructure to use sidenav |
| `app/views/layouts/login.html.erb` | Update to flat naming |
| `app/views/devise/sessions/new.html.erb` | Update to flat naming + btn-primary-big |
| `app/views/users/index.html.erb` | Update all classes |
| `app/views/users/show.html.erb` | Update all classes |
| `app/views/users/_form.html.erb` | Update classes |
| `app/views/profiles/show.html.erb` | Update all classes |
| `app/views/profiles/edit.html.erb` | Update classes |
| `public/visual_tests/index.html` | Update class names + add new component demos |
| `app/assets/stylesheets/old/` | Delete entire directory |

---

## Class equivalence reference

### Layout classes

| Old | New |
|---|---|
| `app-body` | `layout-with-sidebar` |
| `sidebar` | `sidenav` (as `<ul>`) |
| `sidebar__brand` | *(removed — logo via sidenav background-image)* |
| `sidebar__logo` | *(removed)* |
| `sidebar__menu` | *(removed — items directly inside `<ul class="sidenav">`)* |
| `sidebar__item` | `<li>` (no class) |
| `sidebar__item--active` | `sidenav-active` |
| `sidebar__link` | *(no class — `.sidenav li a` handles it)* |
| `sidebar__footer` | `sidenav-footer` |
| `sidebar__link--logout` | *(no class — `.sidenav-logout a` handles it)* |
| `main-content` | `page-content-with-sidebar` |
| `flash flash--notice` | `alert-success` |
| `flash flash--alert` | `alert-error` |

### Login classes

| Old | New |
|---|---|
| `login-page` | `login-page` *(kept in login.css)* |
| `login-stripes` | `login-stripes` *(kept)* |
| `login-stripe--yellow` | `login-stripe-yellow` |
| `login-stripe--blue` | `login-stripe-blue` |
| `login-container` | `login-container` *(kept)* |
| `login-card` | `login-card` *(kept)* |
| `login-card__title` | `login-card-title` |
| `login-form__input` | `login-form-input` |
| `login-form__submit` | `btn-primary-big` |
| `login-flash` | `login-flash` *(kept)* |
| `login-flash__alert` | `login-flash-alert` |

### Button classes (existing → renamed)

| Old | New |
|---|---|
| `btn-yellow-big` | `btn-primary-big` |
| `btn-yellow-small` | `btn-primary` |
| `btn-white` | `btn-secondary` |
| `btn btn--primary` | `btn-primary` |
| `btn btn--danger` | `btn-danger` *(new)* |

### Error/alert classes

| Old | New |
|---|---|
| `.error` (inline tooltip) | `.field-error` |
| `input-error` (input state) | `input-error` *(kept)* |
| `form-errors` (summary block) | `alert-error` |
| `flash flash--notice` | `alert-success` |
| `flash flash--alert` | `alert-error` |
| `login-flash__alert` | `login-flash-alert` *(login-specific, kept in login.css)* |
| *(new)* | `alert-success` |
| *(new)* | `alert-info` |
| *(new)* | `alert-warning` |

### Users/profiles component classes

| Old | New |
|---|---|
| `users-header` | `page-header` |
| `users-search` | `mb-3` |
| `search-form__input` | *(removed — global `input` styling)* |
| `users-list` | `list-card-group` |
| `user-card` | `list-card` |
| `user-card__avatar` | `list-card-avatar` |
| `user-card__info` | `list-card-info` |
| `user-card__username` | `list-card-title` |
| `user-card__role` | `list-card-subtitle` |
| `users-empty` | `empty-state` |
| `users-actions` | `mt-2` |
| `user-detail` | `detail-section` |
| `user-detail__avatar` | `detail-avatar` |
| `user-detail__username` | *(removed — global `<h1>` styling)* |
| `user-detail__role` | `list-card-subtitle` |
| `user-detail__actions` | `detail-actions` |
| `user-form` | `form-container` |
| `form-group` | `form-group` *(kept)* |
| `form-label` | *(removed — global `label` styling)* |
| `form-input` | *(removed — global `input` styling)* |
| `form-hint` | `form-hint` *(kept)* |
| `form-actions` | `form-actions` *(kept)* |
| `profile-card` | `card` |
| `profile-field` | `field-group` |
| `profile-field__label` | `field-label` |
| `profile-field__value` | `field-value` |
| `profile-actions` | `mt-4` |
| `password-form` | `form-container` |
