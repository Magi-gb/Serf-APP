# Authentication & Authorization Plan

## Overview

nDevise-based authentication with role-based access control. Users log in with **username + password**. Three roles: `waiter`, `kitchen_manager`, `admin`.

---

## 1. Dependencies

```ruby
# Gemfile
gem "devise"
```

No extra authorization gem — a simple `before_action` concern is enough for 3 hierarchical roles.

```bash
bundle install
bin/rails generate devise:install
```

Post-install config in `config/initializers/devise.rb`:
- `config.authentication_keys = [:username]`
- `config.case_insensitive_keys = [:username]`
- `config.strip_whitespace_keys = [:username]`

Add to `config/environments/development.rb`:
```ruby
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
```

---

## 2. User model

### Generate & migrate

```bash
bin/rails generate devise User
```

Edit the generated migration:

```ruby
class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string  :username,           null: false, default: ""
      t.string  :encrypted_password, null: false, default: ""
      t.integer :role,               null: false, default: 0
      t.timestamps null: false
    end

    add_index :users, :username, unique: true
  end
end
```

No email, no recoverable, no rememberable — just username, password, and role.

### Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable

  enum :role, { waiter: 0, kitchen_manager: 1, admin: 2 }

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :role, presence: true

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
```

Only one Devise module: `database_authenticatable`. We skip `:validatable` because it enforces email format.

### Tests (`test/models/user_test.rb`)

- Valid user creation with username, password, role
- Uniqueness of username
- Password minimum length validation
- Role enum values (`waiter?`, `kitchen_manager?`, `admin?`)
- Default role is `waiter`
- Cannot save without username
- Cannot save without password (on create)

---

## 3. Disable self-registration

No `:registerable` module → no sign-up route. Admin user CRUD will come later.

```ruby
# config/routes.rb
devise_for :users, skip: [:registrations, :passwords]
```

Exposed routes:
- `GET  /users/sign_in` — login form
- `POST /users/sign_in` — authenticate
- `DELETE /users/sign_out` — logout

---

## 4. Username login view

```bash
bin/rails generate devise:views
```

Edit `app/views/devise/sessions/new.html.erb`:
- Replace email field with username field
- Remove registration and password recovery links

Delete all generated views we don't use (registrations, passwords, confirmations, etc.) to avoid clutter.

---

## 5. ApplicationController

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
end
```

No need for `configure_permitted_parameters` — username is already the authentication key via the initializer, and Devise permits authentication keys by default for sign-in.

---

## 6. Authorization (role-based)

```ruby
# app/controllers/concerns/authorizable.rb
module Authorizable
  extend ActiveSupport::Concern

  private

  def require_admin!
    deny_access! unless current_user.admin?
  end

  def require_kitchen_manager_or_above!
    deny_access! unless current_user.admin? || current_user.kitchen_manager?
  end

  def deny_access!
    redirect_to root_path, alert: "You are not authorized to access this page."
  end
end
```

Include in `ApplicationController`:
```ruby
include Authorizable
```

### Role access matrix

| Resource | Waiter | Kitchen Manager | Admin |
|---|:---:|:---:|:---:|
| View menus / dishes | yes | yes | yes |
| Suggestion engine | yes | yes | yes |
| CRUD menus, dishes, ingredients, restrictions | no | yes | yes |
| Manage users | no | no | yes |

### Tests (`test/controllers/concerns/authorizable_test.rb`)

- `require_admin!` allows admin, rejects waiter and kitchen_manager
- `require_kitchen_manager_or_above!` allows admin and kitchen_manager, rejects waiter
- Denied users are redirected with an alert message

---

## 7. Seed data

```ruby
# db/seeds.rb
User.find_or_create_by!(username: "admin") do |u|
  u.password = "password"
  u.role = :admin
end
```

---

## 8. Integration tests (`test/integration/authentication_test.rb`)

- Unauthenticated user is redirected to sign-in
- Sign in with valid credentials succeeds
- Sign in with wrong password fails
- Sign in with nonexistent username fails
- Sign out works

---

## 9. Implementation steps

1. Add `devise` gem → `bundle install`
2. `bin/rails generate devise:install` → configure initializer (username keys)
3. `bin/rails generate devise User` → edit migration (username + role only)
4. Edit `User` model (single Devise module, enum, validations)
5. Update `config/routes.rb` (skip registrations + passwords)
6. `bin/rails generate devise:views` → customize sign-in view, delete unused views
7. Update `ApplicationController` (`authenticate_user!`)
8. Create `Authorizable` concern
9. Write seed data
10. `bin/rails db:migrate && bin/rails db:seed`
11. Write tests (model + authorization concern + integration)
12. `bin/rubocop && bin/brakeman` — fix any issues

---

## 10. Files created / modified

| File | Action |
|---|---|
| `Gemfile` | Add `devise` |
| `config/initializers/devise.rb` | Generated + configured |
| `config/environments/development.rb` | Add mailer URL options |
| `config/routes.rb` | Add `devise_for` |
| `db/migrate/xxx_devise_create_users.rb` | Generated + customized |
| `app/models/user.rb` | Generated + customized |
| `app/controllers/application_controller.rb` | Add `authenticate_user!` |
| `app/controllers/concerns/authorizable.rb` | New |
| `app/views/devise/sessions/new.html.erb` | Generated + customized |
| `db/seeds.rb` | Add admin seed |
| `test/models/user_test.rb` | New |
| `test/controllers/concerns/authorizable_test.rb` | New |
| `test/integration/authentication_test.rb` | New |

---

## 11. Future work (out of scope)

- Admin user CRUD (`UsersController`)
- Post-login redirects per role
- Password recovery (`:recoverable`)
- Account lockout (`:lockable`)