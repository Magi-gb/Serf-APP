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

ActiveRecord::Schema[7.2].define(version: 2026_05_31_200000) do
  create_table "dish_elaborations", force: :cascade do |t|
    t.integer "dish_id", null: false
    t.integer "elaboration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id", "elaboration_id"], name: "index_dish_elaborations_on_dish_and_elaboration", unique: true
    t.index ["dish_id"], name: "index_dish_elaborations_on_dish_id"
    t.index ["elaboration_id"], name: "index_dish_elaborations_on_elaboration_id"
  end

  create_table "dish_ingredients", force: :cascade do |t|
    t.integer "dish_id", null: false
    t.integer "ingredient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "essential", default: true, null: false
    t.index ["dish_id", "ingredient_id"], name: "index_dish_ingredients_on_dish_id_and_ingredient_id", unique: true
    t.index ["dish_id"], name: "index_dish_ingredients_on_dish_id"
    t.index ["ingredient_id"], name: "index_dish_ingredients_on_ingredient_id"
  end

  create_table "dishes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dish_type", default: 0, null: false
    t.check_constraint "dish_type IN (0, 1, 2, 3)", name: "chk_dishes_dish_type"
  end

  create_table "elaboration_ingredients", force: :cascade do |t|
    t.integer "elaboration_id", null: false
    t.integer "ingredient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["elaboration_id", "ingredient_id"], name: "index_elaboration_ingredients_on_elaboration_and_ingredient", unique: true
    t.index ["elaboration_id"], name: "index_elaboration_ingredients_on_elaboration_id"
    t.index ["ingredient_id"], name: "index_elaboration_ingredients_on_ingredient_id"
  end

  create_table "elaborations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_elaborations_on_name", unique: true
  end

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

  create_table "menu_dishes", force: :cascade do |t|
    t.integer "menu_id", null: false
    t.integer "dish_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_menu_dishes_on_dish_id"
    t.index ["menu_id", "dish_id"], name: "index_menu_dishes_on_menu_id_and_dish_id", unique: true
    t.index ["menu_id"], name: "index_menu_dishes_on_menu_id"
  end

  create_table "menus", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_menus_on_name", unique: true
  end

  create_table "protocols", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bg_color"
    t.text "icon_svg"
    t.index ["name"], name: "index_protocols_on_name", unique: true
  end

  create_table "restrictions", force: :cascade do |t|
    t.string "name", null: false
    t.integer "restriction_type", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "severity", default: 1, null: false
    t.integer "ingredients_count", default: 0, null: false
    t.integer "elaborations_count", default: 0, null: false
    t.integer "dishes_count", default: 0, null: false
    t.integer "menus_count", default: 0, null: false
    t.index ["name"], name: "index_restrictions_on_name", unique: true
    t.check_constraint "dishes_count >= 0", name: "chk_restrictions_dishes_count"
    t.check_constraint "elaborations_count >= 0", name: "chk_restrictions_elaborations_count"
    t.check_constraint "ingredients_count >= 0", name: "chk_restrictions_ingredients_count"
    t.check_constraint "menus_count >= 0", name: "chk_restrictions_menus_count"
    t.check_constraint "restriction_type IN (0, 1)", name: "chk_restrictions_restriction_type"
    t.check_constraint "severity IN (0, 1, 2)", name: "chk_restrictions_severity"
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

  add_foreign_key "dish_elaborations", "dishes"
  add_foreign_key "dish_elaborations", "elaborations"
  add_foreign_key "dish_ingredients", "dishes"
  add_foreign_key "dish_ingredients", "ingredients"
  add_foreign_key "elaboration_ingredients", "elaborations"
  add_foreign_key "elaboration_ingredients", "ingredients"
  add_foreign_key "ingredient_restrictions", "ingredients"
  add_foreign_key "ingredient_restrictions", "restrictions"
  add_foreign_key "menu_dishes", "dishes"
  add_foreign_key "menu_dishes", "menus"
end
