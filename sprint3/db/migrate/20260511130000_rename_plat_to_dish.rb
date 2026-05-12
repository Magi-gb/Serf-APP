class RenamePlatToDish < ActiveRecord::Migration[7.2]
  def change
    rename_table :plats, :dishes
    rename_table :menu_plats, :menu_dishes
    rename_table :plat_ingredients, :dish_ingredients

    rename_column :dishes, :tipusPlat, :dish_type
    rename_column :menu_dishes, :plat_id, :dish_id
    rename_column :dish_ingredients, :plat_id, :dish_id
  end
end
