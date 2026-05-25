# Best-effort coverage estimator: counts how many dishes in a menu are
# "safe" for a list of well-known restriction names. A dish is considered
# compatible with restriction X when none of its ingredients carry X.
#
# Without a `DishIngredient#essential` flag we cannot tell whether an
# offending ingredient could be substituted — so a dish that contains an
# ingredient with restriction X is reported as *not* compatible. Adding
# `essential` later will let us refine "no substitution possible" vs.
# "may be adapted on request".
class MenuCoverage
  Slot = Struct.new(:key, :restriction_name, :tag_kind)

  COMMON_SLOTS = [
    Slot.new(:gluten, "Gluten (Cereals)", "allergen"),
    Slot.new(:lactose, "Llet", "intolerance"),
    Slot.new(:vegetarian, "Vegetarià", "preference"),
    Slot.new(:vegan, "Vegà", "preference")
  ].freeze

  def initialize(menu)
    @menu = menu
  end

  # @return [Array<Hash>] one entry per slot with :key, :restriction, :compatible, :total, :tag_kind.
  def call
    total = @menu.dishes.size
    COMMON_SLOTS.map do |slot|
      restriction = Restriction.find_by(name: slot.restriction_name)
      compatible = restriction ? count_compatible(restriction) : total
      { key: slot.key, restriction: restriction, compatible: compatible, total: total, tag_kind: slot.tag_kind }
    end
  end

  private

  def count_compatible(restriction)
    @menu.dishes.count do |dish|
      dish.ingredients.none? { |ing| ing.restrictions.include?(restriction) }
    end
  end
end
