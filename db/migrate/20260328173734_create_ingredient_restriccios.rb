class CreateIngredientRestriccios < ActiveRecord::Migration[7.2]
  def change
    create_table :ingredient_restriccios do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.references :restriccio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
