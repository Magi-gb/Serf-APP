class AddCheckConstraintToDishesAndUniqueIndexToMenus < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :dishes, "dish_type IN (0, 1, 2, 3)", name: "chk_dishes_dish_type"
    add_index :menus, :name, unique: true
  end
end
