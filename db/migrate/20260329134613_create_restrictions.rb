class CreateRestrictions < ActiveRecord::Migration[7.2]
  def change
    create_table :restrictions do |t|
      t.string :name
      t.text :description
      t.string :bg_color

      t.timestamps
    end
  end
end
