class AddSeverityToRestrictions < ActiveRecord::Migration[7.2]
  def change
    add_column :restrictions, :severity, :integer, null: false, default: 1
    add_check_constraint :restrictions, "severity IN (0, 1, 2)", name: "chk_restrictions_severity"
  end
end
