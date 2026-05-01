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

ActiveRecord::Schema[7.2].define(version: 2026_05_01_065010) do
  create_table "ingredient_alternatives", force: :cascade do |t|
    t.integer "ingredient_id", null: false
    t.integer "alternative_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alternative_id"], name: "index_ingredient_alternatives_on_alternative_id"
    t.index ["ingredient_id", "alternative_id"], name: "idx_on_ingredient_id_alternative_id_d7c7e5c594", unique: true
    t.index ["ingredient_id"], name: "index_ingredient_alternatives_on_ingredient_id"
    t.check_constraint "ingredient_id != alternative_id", name: "ingredient_alternative_not_self"
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

  create_table "protocols", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_protocols_on_name", unique: true
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

  add_foreign_key "ingredient_alternatives", "ingredients"
  add_foreign_key "ingredient_alternatives", "ingredients", column: "alternative_id"
  add_foreign_key "ingredient_restrictions", "ingredients"
  add_foreign_key "ingredient_restrictions", "restrictions"
end
