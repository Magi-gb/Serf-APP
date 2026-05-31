class AddEssentialToDishIngredients < ActiveRecord::Migration[7.2]
  def change
    add_column :dish_ingredients, :essential, :boolean, null: false, default: false
  end
end
