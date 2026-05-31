class CreateDishElaborations < ActiveRecord::Migration[7.2]
  def change
    create_table :dish_elaborations do |t|
      t.references :dish, null: false, foreign_key: true
      t.references :elaboration, null: false, foreign_key: true

      t.timestamps
    end

    add_index :dish_elaborations, [ :dish_id, :elaboration_id ], unique: true, name: "index_dish_elaborations_on_dish_and_elaboration"
  end
end
