class AddNonNegativeCheckToRestrictionCounterCaches < ActiveRecord::Migration[7.2]
  # The four counter caches must never go below zero. No matching ActiveRecord
  # validation accompanies these checks on purpose: the columns are managed by
  # the framework (counter_cache) and by update_columns in
  # Restriction#recalculate_all_cached_counts!, both of which bypass validations,
  # so a model-level validation would never fire. The DB CHECK is the only layer
  # that can actually guard these values.
  def change
    add_check_constraint :restrictions, "ingredients_count >= 0", name: "chk_restrictions_ingredients_count"
    add_check_constraint :restrictions, "elaborations_count >= 0", name: "chk_restrictions_elaborations_count"
    add_check_constraint :restrictions, "dishes_count >= 0", name: "chk_restrictions_dishes_count"
    add_check_constraint :restrictions, "menus_count >= 0", name: "chk_restrictions_menus_count"
  end
end
