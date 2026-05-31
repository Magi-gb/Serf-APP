class RemoveVisualsFromRestrictions < ActiveRecord::Migration[7.2]
  def change
    remove_column :restrictions, :bg_color, :string
    remove_column :restrictions, :icon_svg, :text
  end
end
