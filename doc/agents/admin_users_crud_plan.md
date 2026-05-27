# Admin Dashboard & Users CRUD Plan

## Overview

Implement the application layout with a sidebar navigation (matching the mockup), a Users CRUD for admin management, and a profile page for self-management (change own password). All roles see the sidebar; some items are hidden based on role.

---

## 1. Application layout with sidebar

### Structure

The `application.html.erb` layout gets a sidebar + main content area:

```
┌──────────┬──────────────────────────────┐
│  Sidebar │  Main content area           │
│          │  ┌─ flash messages ─┐        │
│  SerF    │  │                  │        │
│  logo    │  └──────────────────┘        │
│          │  ┌─ yield ──────────┐        │
│  Menu    │  │                  │        │
│  items   │  │                  │        │
│          │  │                  │        │
│          │  └──────────────────┘        │
│  ───     │                              │
│  Logout  │                              │
└──────────┴──────────────────────────────┘
```

### Sidebar items

| Item | Route | Visible to | Status |
|---|---|---|---|
| Personal | `users_path` | admin only | Implemented |
| Placeholder | `#` | all roles | Disabled link |
| Tancar sessió | `destroy_user_session_path` | all roles | Logout |

The sidebar is a partial (`app/views/layouts/_sidebar.html.erb`) rendered within the application layout. Menu items are conditionally shown based on `current_user.role`.

### CSS

New file `app/assets/stylesheets/layout.css`:
- Flexbox: sidebar (fixed width ~200px) + main content (flex: 1)
- Sidebar: blue background (#3a5dae), white text, brand logo at top
- Active item highlighted (beige/cream background matching mockup)
- Logout button at bottom (pushed down with `margin-top: auto`)
- Flash messages styled inside main content area

---

## 2. Post-login redirect

Override Devise's `after_sign_in_path_for` in `ApplicationController`:

```ruby
def after_sign_in_path_for(resource)
  resource.admin? ? users_path : root_path
end
```

Admin lands on users index. Other roles land on root (home) for now.

---

## 3. Users CRUD (admin only)

### Routes

```ruby
resources :users
```

Protected by `before_action :require_admin!` in `UsersController`.

### Controller: `UsersController`

| Action | Purpose |
|---|---|
| `index` | List all users, with optional search by username (`params[:search]`) |
| `show` | View a single user's details |
| `new` | Form to create a new user |
| `create` | Save new user |
| `edit` | Form to edit user (username, role, optionally password) |
| `update` | Save changes |
| `destroy` | Delete user (cannot delete self) |

**Search:** `index` filters with `User.where("username LIKE ?", "%#{search}%")` when `params[:search]` is present.

**Strong params:** `username`, `role`, `password`, `password_confirmation`. Password is optional on update (only changed if provided).

**Destroy guard:** Cannot delete yourself — redirect back with alert if attempted.

### Views

**`index.html.erb`:**
- Search bar at top ("Cerca un usuari!")
- List of user cards, each showing: colored avatar circle (initial letter), username, role translated to Catalan
- "Nou usuari!" button (links to `new_user_path`)

**`show.html.erb`:**
- User card with username, role
- "Editar dades" button → `edit_user_path`
- "Eliminar" button → `user_path` with DELETE method + confirmation

**`new.html.erb` / `edit.html.erb`:**
- Shared form partial `_form.html.erb`
- Fields: username, role (select dropdown), password, password_confirmation
- On edit, password fields are optional (blank = no change)

**`_form.html.erb`:**
- Displays validation errors if any
- Username text field
- Role select (Catalan labels: "Cambrer", "Responsable de cuina", "Administrador")
- Password + confirmation fields
- Submit button

### CSS

New file `app/assets/stylesheets/users.css`:
- User cards: beige/cream background (#f2ece0), rounded, with avatar circle
- Avatar: colored circle with first letter of username
- Search bar: yellow background (#f5c518), rounded, matching mockup
- Form styling consistent with login page (same input style, same button style)

---

## 4. Profile (self-management)

### Route

```ruby
resource :profile, only: [ :show, :edit, :update ]
```

Singular resource — no `:id` needed, always operates on `current_user`.

### Controller: `ProfilesController`

- `show` — display current user info
- `edit` — form to change own password
- `update` — save password change (requires current password for confirmation)

No role restriction — all authenticated users can manage their own profile.

**Strong params:** `current_password`, `password`, `password_confirmation`.

**Update logic:** Verify `current_password` matches before allowing password change. On success, re-sign in the user (Devise signs out on password change otherwise).

### Views

**`show.html.erb`:**
- Username (read-only), role (read-only)
- "Canviar contrasenya" button → `edit_profile_path`

**`edit.html.erb`:**
- Current password field
- New password + confirmation fields
- Submit button

---

## 5. Seeds

Add more users for development:

```ruby
User.find_or_create_by!(username: "admin") do |u|
  u.password = "password"
  u.role = :admin
end

User.find_or_create_by!(username: "cuiner") do |u|
  u.password = "password"
  u.role = :kitchen_manager
end

User.find_or_create_by!(username: "cambrer") do |u|
  u.password = "password"
  u.role = :waiter
end
```

---

## 6. I18n additions (`config/locales/ca.yml`)

```yaml
# Sidebar
sidebar:
  personal: "Personal"
  placeholder: "Placeholder"
  logout: "Tancar sessió"

# Users CRUD
users:
  index:
    title: "Personal"
    search_placeholder: "Cerca un usuari!"
    new_user: "Nou usuari!"
    no_users: "No s'han trobat usuaris."
  show:
    title: "Detalls de l'usuari"
    edit: "Editar dades"
    delete: "Eliminar"
    confirm_delete: "Segur que vols eliminar aquest usuari?"
  new:
    title: "Nou usuari"
  edit:
    title: "Editar usuari"
  form:
    username: "Nom d'usuari"
    role: "Rol"
    password: "Contrasenya"
    password_confirmation: "Confirmar contrasenya"
    password_hint_edit: "(deixa en blanc per no canviar)"
    submit_create: "Crear usuari"
    submit_update: "Desar canvis"
  roles:
    waiter: "Cambrer"
    kitchen_manager: "Responsable de cuina"
    admin: "Administrador"
  destroy:
    success: "Usuari eliminat correctament."
    cannot_delete_self: "No pots eliminar el teu propi compte."
  create:
    success: "Usuari creat correctament."
  update:
    success: "Usuari actualitzat correctament."

# Profile
profile:
  show:
    title: "El meu perfil"
    change_password: "Canviar contrasenya"
  edit:
    title: "Canviar contrasenya"
    current_password: "Contrasenya actual"
    new_password: "Nova contrasenya"
    new_password_confirmation: "Confirmar nova contrasenya"
    submit: "Desar"
  update:
    success: "Contrasenya actualitzada correctament."
    invalid_current_password: "La contrasenya actual no és correcta."
```

---

## 7. Tests

### Model tests (additions to `user_test.rb`)
- Search scope: returns matching users, excludes non-matching

### Controller tests: `UsersController`

**Admin access (happy path):**
- `index` lists all users
- `index` with search param filters users
- `show` displays user
- `new` renders form
- `create` with valid params creates user and redirects
- `create` with invalid params re-renders form
- `edit` renders form
- `update` with valid params updates user and redirects
- `update` without password doesn't clear password
- `update` with invalid params re-renders form
- `destroy` deletes user and redirects
- `destroy` self is rejected

**Authorization (rejection):**
- Waiter cannot access any users action
- Kitchen manager cannot access any users action

### Controller tests: `ProfilesController`

- `show` displays current user profile
- `edit` renders password form
- `update` with correct current password changes password
- `update` with wrong current password re-renders with error
- All roles can access profile

### Integration tests

- Admin logs in and lands on users index
- Non-admin logs in and lands on root
- Sidebar shows "Personal" for admin, hides it for waiter

---

## 8. Implementation steps

1. Create application layout with sidebar (layout + partial + CSS)
2. Add post-login redirect logic
3. Add search scope to User model
4. Create `UsersController` with all CRUD actions
5. Create Users views (index, show, new, edit, _form)
6. Create Users CSS
7. Create `ProfilesController` with show/edit/update
8. Create Profile views (show, edit)
9. Update routes (resources :users, resource :profile)
10. Add all I18n keys to `ca.yml`
11. Update seeds with extra users
12. Update fixtures if needed
13. Write all tests
14. Run rubocop + brakeman + all tests

---

## 9. Files created / modified

| File | Action |
|---|---|
| `app/views/layouts/application.html.erb` | Rewrite with sidebar structure |
| `app/views/layouts/_sidebar.html.erb` | New — sidebar partial |
| `app/assets/stylesheets/layout.css` | New — sidebar + main content styles |
| `app/assets/stylesheets/users.css` | New — user cards, search, forms |
| `app/controllers/application_controller.rb` | Add `after_sign_in_path_for` |
| `app/controllers/users_controller.rb` | New — full CRUD |
| `app/controllers/profiles_controller.rb` | New — show/edit/update |
| `app/views/users/index.html.erb` | New |
| `app/views/users/show.html.erb` | New |
| `app/views/users/new.html.erb` | New |
| `app/views/users/edit.html.erb` | New |
| `app/views/users/_form.html.erb` | New |
| `app/views/profiles/show.html.erb` | New |
| `app/views/profiles/edit.html.erb` | New |
| `app/models/user.rb` | Add search scope |
| `config/routes.rb` | Add resources :users, resource :profile |
| `config/locales/ca.yml` | Add all new keys |
| `db/seeds.rb` | Add extra users |
| `test/models/user_test.rb` | Add search scope tests |
| `test/controllers/users_controller_test.rb` | New |
| `test/controllers/profiles_controller_test.rb` | New |
| `test/integration/post_login_redirect_test.rb` | New |
