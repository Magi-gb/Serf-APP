class AddDescriptionToMenus < ActiveRecord::Migration[7.2]
  def change
    add_column :menus, :description, :text, null: false, default: ""

    # remove default after populating existing rows if necessary
    change_column_default :menus, :description, from: "", to: nil
  end
end
