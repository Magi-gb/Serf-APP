class AddUniqueIndexToMenusName < ActiveRecord::Migration[7.2]
  def change
    add_index :menus, :name, unique: true
  end
end
