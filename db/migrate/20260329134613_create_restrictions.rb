class CreateRestrictions < ActiveRecord::Migration[7.2]
  def change
    create_table :restrictions do |t|
      t.string :name, null: false
      t.integer :restriction_type, null: false
      t.text :description
      t.string :bg_color
      t.text :icon_svg

      t.timestamps
    end
    add_index :restrictions, :name, unique: true
  end
end
