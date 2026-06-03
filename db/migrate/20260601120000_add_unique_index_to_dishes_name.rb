class AddUniqueIndexToDishesName < ActiveRecord::Migration[7.2]
  def change
    add_index :dishes, :name, unique: true
  end
end
