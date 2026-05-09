class AddTipusPlatToPlats < ActiveRecord::Migration[7.1]
  def change
    add_column :plats, :tipusPlat, :integer, default: 0, null: false
  end
end
