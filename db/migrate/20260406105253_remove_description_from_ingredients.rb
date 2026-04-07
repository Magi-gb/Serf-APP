class RemoveDescriptionFromIngredients < ActiveRecord::Migration[7.2]
  def change
    remove_column :ingredients, :description, :text
  end
end
