class DropIngredientAlternatives < ActiveRecord::Migration[7.2]
  def change
    drop_table :ingredient_alternatives do |t|
      t.bigint :ingredient_id, null: false
      t.bigint :alternative_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :alternative_id
      t.index [ :ingredient_id, :alternative_id ], unique: true
      t.index :ingredient_id
      t.check_constraint "ingredient_id != alternative_id", name: "ingredient_alternative_not_self"
    end
  end
end
