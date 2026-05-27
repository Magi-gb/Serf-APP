class CreatePreparations < ActiveRecord::Migration[7.2]
  def change
    create_table :preparations do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :preparations, :name, unique: true
  end
end
