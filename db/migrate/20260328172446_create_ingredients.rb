class CreateIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :ingredients, :name, unique: true
  end
end
