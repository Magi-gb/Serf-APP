class AddUniqueIndexToPlatIngredients < ActiveRecord::Migration[7.2]
  def change
    add_index :plat_ingredients, [ :plat_id, :ingredient_id ], unique: true
  end
end
