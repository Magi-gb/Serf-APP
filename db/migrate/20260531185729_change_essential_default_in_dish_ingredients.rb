class ChangeEssentialDefaultInDishIngredients < ActiveRecord::Migration[7.2]
  def change
    change_column_default :dish_ingredients, :essential, from: false, to: true
    DishIngredient.update_all(essential: true)
  end
end
