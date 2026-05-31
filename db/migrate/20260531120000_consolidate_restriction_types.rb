class ConsolidateRestrictionTypes < ActiveRecord::Migration[7.2]
  # The restrictions catalog only distinguishes two types: intolerance/allergy (0)
  # and diet (1) — religious and preference restrictions are all treated as diets.
  # A removed third type (2) may still linger in older databases, where the enum
  # reads it as nil. Re-map those rows to diet and tighten the check constraint so
  # only the two supported types remain valid.
  def up
    execute "UPDATE restrictions SET restriction_type = 1 WHERE restriction_type = 2"

    remove_check_constraint :restrictions, name: "chk_restrictions_restriction_type"
    add_check_constraint :restrictions, "restriction_type IN (0, 1)", name: "chk_restrictions_restriction_type"
  end

  def down
    remove_check_constraint :restrictions, name: "chk_restrictions_restriction_type"
    add_check_constraint :restrictions, "restriction_type IN (0, 1, 2)", name: "chk_restrictions_restriction_type"
  end
end
