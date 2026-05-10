# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_09_154547) do
  create_table "ingredient_restrictions", force: :cascade do |t|
    t.integer "ingredient_id", null: false
    t.integer "restriction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id", "restriction_id"], name: "idx_on_ingredient_id_restriction_id_97ea466c4a", unique: true
    t.index ["ingredient_id"], name: "index_ingredient_restrictions_on_ingredient_id"
    t.index ["restriction_id"], name: "index_ingredient_restrictions_on_restriction_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "menu_plats", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.integer "plat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id", "plat_id"], name: "index_menu_plats_on_menu_id_and_plat_id", unique: true
    t.index ["menu_id"], name: "index_menu_plats_on_menu_id"
    t.index ["plat_id"], name: "index_menu_plats_on_plat_id"
  end

  create_table "menus", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plat_ingredients", force: :cascade do |t|
    t.integer "plat_id", null: false
    t.integer "ingredient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_plat_ingredients_on_ingredient_id"
    t.index ["plat_id"], name: "index_plat_ingredients_on_plat_id"
  end

  create_table "plats", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tipusPlat", default: 0, null: false
  end

  create_table "restrictions", force: :cascade do |t|
    t.string "name", null: false
    t.integer "restriction_type", null: false
    t.text "description"
    t.string "bg_color"
    t.text "icon_svg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_restrictions_on_name", unique: true
    t.check_constraint "restriction_type IN (0, 1)", name: "chk_restrictions_restriction_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
    t.check_constraint "role IN (0, 1, 2)", name: "chk_users_role"
  end

  add_foreign_key "ingredient_restrictions", "ingredients"
  add_foreign_key "ingredient_restrictions", "restrictions"
  add_foreign_key "menu_plats", "menus"
  add_foreign_key "menu_plats", "plats"
  add_foreign_key "plat_ingredients", "ingredients"
  add_foreign_key "plat_ingredients", "plats"
end
