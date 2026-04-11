class CreateIngredientRestrictions < ActiveRecord::Migration[7.2]
  def change
    create_table :ingredient_restrictions do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.references :restriction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
