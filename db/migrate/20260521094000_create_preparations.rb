class CreatePreparations < ActiveRecord::Migration[7.2]
  def change
    create_table :preparations do |t|
      t.string :name, null: false
      t.text :description
      t.integer :time_minutes, null: false
      t.integer :difficulty, null: false, default: 0
      t.references :dish, null: true, foreign_key: true

      t.timestamps
    end

    add_index :preparations, :name, unique: true
    add_check_constraint :preparations, "time_minutes > 0", name: "chk_preparations_time_minutes"
    add_check_constraint :preparations, "difficulty IN (0, 1, 2)", name: "chk_preparations_difficulty"
  end
end
