class EnforcePlatsNameNotNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :plats, :name, false
  end
end
