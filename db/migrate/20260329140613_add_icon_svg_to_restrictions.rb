class AddIconSvgToRestrictions < ActiveRecord::Migration[7.2]
  def change
    add_column :restrictions, :icon_svg, :text
  end
end
