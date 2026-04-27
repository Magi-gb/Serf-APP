class AddUniquenessToIngredientRestrictions < ActiveRecord::Migration[7.2]
  def change
    add_index :ingredient_restrictions, [ :ingredient_id, :restriction_id ], unique: true
  end
end
