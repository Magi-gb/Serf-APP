class SimplifyMenus < ActiveRecord::Migration[7.2]
  def change
    remove_column :menus, :code
    remove_column :menus, :description
    remove_column :menus, :starts_on
    remove_column :menus, :ends_on
  end
end
