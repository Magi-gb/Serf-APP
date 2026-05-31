class CreateElaborations < ActiveRecord::Migration[7.2]
  def change
    create_table :elaborations do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :elaborations, :name, unique: true
  end
end
