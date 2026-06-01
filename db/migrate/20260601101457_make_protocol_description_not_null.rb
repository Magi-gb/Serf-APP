class MakeProtocolDescriptionNotNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :protocols, :description, false, ""
  end
end
