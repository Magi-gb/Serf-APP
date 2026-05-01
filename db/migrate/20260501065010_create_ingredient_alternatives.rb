class CreateIngredientAlternatives < ActiveRecord::Migration[7.2]
  def change
    create_table :ingredient_alternatives do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.references :alternative, null: false, foreign_key: { to_table: :ingredients }

      t.timestamps
    end

    add_index :ingredient_alternatives, [ :ingredient_id, :alternative_id ], unique: true
    add_check_constraint :ingredient_alternatives, "ingredient_id != alternative_id", name: "ingredient_alternative_not_self"
  end
end
