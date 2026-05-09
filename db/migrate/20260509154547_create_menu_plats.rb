class CreateMenuPlats < ActiveRecord::Migration[7.2]
  def change
    create_table :menu_plats do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :plat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
