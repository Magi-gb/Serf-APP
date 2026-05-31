# Returns one entry per restriction that is violated by at least one dish in
# the menu. A dish is considered to violate restriction X when any of its
# ingredients carries X. Without DishIngredient#essential we cannot tell
# "substitutable" from "blocking", so any matching ingredient counts.
class MenuCoverage
  def initialize(menu)
    @menu = menu
  end

  # @return [Array<Hash>] one entry per violated restriction with
  #   :restriction, :violated, :total, :tag_kind. Empty when no violations.
  def call
    dish_ids = @menu.dishes.map(&:id)
    return [] if dish_ids.empty?

    total = dish_ids.size
    @dishes = Dish.where(id: dish_ids)
                  .includes(ingredients: :restrictions,
                            elaborations: { ingredients: :restrictions })
                  .to_a

    Restriction.order(:name).filter_map do |restriction|
      violated = count_violated(restriction)
      next if violated.zero?

      { restriction: restriction, violated: violated, total: total, tag_kind: tag_kind_for(restriction) }
    end
  end

  private

  def count_violated(restriction)
    @dishes.count do |dish|
      all_ingredients = dish.ingredients + dish.elaborations.flat_map(&:ingredients)
      all_ingredients.any? { |ing| ing.restrictions.include?(restriction) }
    end
  end

  def tag_kind_for(restriction)
    restriction.intolerance_allergy? ? "allergen" : "diet"
  end
end
