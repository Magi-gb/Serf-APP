# Suggests alternative dishes for a given dish, e.g. when a diner cannot eat it
# because of a dietary restriction. This is the project's suggestion engine and
# lives here (rather than on the model) per the documented architecture.
class SuggestionService
  def initialize(dish)
    @dish = dish
  end

  # Finds dishes that can be offered as alternatives to the wrapped dish.
  #
  # A candidate is similar when it shares the dish's category (+dish_type+) and
  # carries none of the given restrictions through its ingredients. Candidates
  # are ranked by the number of ingredients they share with the dish, and the
  # five closest matches are returned (most similar first).
  #
  # @param restrictions_to_exclude [Enumerable<Restriction>] restrictions that a
  #   similar dish must not carry through any of its ingredients.
  # @return [Array<Dish>] up to five similar dishes, ordered by descending
  #   number of shared ingredients.
  def alternatives(restrictions_to_exclude)
    excluded_ids = restrictions_to_exclude.map(&:id).to_set
    own_ingredient_ids = @dish.ingredient_ids.to_set

    # Same category and not the dish itself. Eager-load ingredients and elaborations
    # (with their ingredients and restrictions) to avoid N+1 queries.
    candidates = Dish.where(dish_type: @dish.dish_type)
                     .where.not(id: @dish.id)
                     .includes(ingredients: :restrictions,
                               elaborations: { ingredients: :restrictions })

    # Discard any candidate carrying an excluded restriction through any ingredient
    # (direct or via an elaboration).
    compatible = candidates.reject do |dish|
      all_ingredients = dish.ingredients + dish.elaborations.flat_map(&:ingredients)
      all_ingredients.any? { |ingredient| ingredient.restrictions.any? { |r| excluded_ids.include?(r.id) } }
    end

    # Rank by shared-ingredient count (descending) and keep the top five.
    compatible
      .sort_by { |dish| -dish.ingredients.count { |ingredient| own_ingredient_ids.include?(ingredient.id) } }
      .first(5)
  end
end
