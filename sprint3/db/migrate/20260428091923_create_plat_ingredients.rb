class CreatePlatIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :plat_ingredients do |t|
      t.references :plat, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true

      t.timestamps
    end
  end
end
