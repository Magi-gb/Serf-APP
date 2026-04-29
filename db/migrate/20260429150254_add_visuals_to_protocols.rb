class AddVisualsToProtocols < ActiveRecord::Migration[7.2]
  def change
    add_column :protocols, :bg_color, :string
    add_column :protocols, :icon_svg, :text
  end
end
