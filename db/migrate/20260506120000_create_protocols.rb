class CreateProtocols < ActiveRecord::Migration[7.0]
  def change
    create_table :protocols do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :protocols, :name, unique: true
  end
end
