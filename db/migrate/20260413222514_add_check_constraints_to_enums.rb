class AddCheckConstraintsToEnums < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :restrictions, "restriction_type IN (0, 1)", name: "chk_restrictions_restriction_type"
    add_check_constraint :users, "role IN (0, 1, 2)", name: "chk_users_role"
  end
end
