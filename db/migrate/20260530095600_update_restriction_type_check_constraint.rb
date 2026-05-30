class UpdateRestrictionTypeCheckConstraint < ActiveRecord::Migration[7.1]
  def change
    remove_check_constraint :restrictions,
      name: "chk_restrictions_restriction_type"

    add_check_constraint :restrictions,
      "restriction_type IN (0, 1, 2)",
      name: "chk_restrictions_restriction_type"
  end
end