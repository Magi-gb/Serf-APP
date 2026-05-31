class RemoveVisualFieldsFromProtocols < ActiveRecord::Migration[7.2]
  def change
    remove_column :protocols, :bg_color, :string
    remove_column :protocols, :icon_svg, :text
  end
end
