class CreateElaborationIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :elaboration_ingredients do |t|
      t.references :elaboration, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true

      t.timestamps
    end

    add_index :elaboration_ingredients, [ :elaboration_id, :ingredient_id ], unique: true, name: "index_elaboration_ingredients_on_elaboration_and_ingredient"
  end
end
