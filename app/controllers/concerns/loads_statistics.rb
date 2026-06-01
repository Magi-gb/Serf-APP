module LoadsStatistics
  extend ActiveSupport::Concern

  private

  def load_statistics
    @restrictions_stats = Restriction.all.map do |restriction|
      dishes_count = Dish
        .joins(ingredients: :ingredient_restrictions)
        .where(ingredient_restrictions: { restriction_id: restriction.id })
        .distinct
        .count

      menus_count = Menu
        .joins(dishes: { ingredients: :ingredient_restrictions })
        .where(ingredient_restrictions: { restriction_id: restriction.id })
        .distinct
        .count

      {
        restriction: restriction,
        dishes_count: dishes_count,
        menus_count: menus_count
      }
    end.sort_by { |s| -s[:dishes_count] }

    @total_dishes_count = Dish.count
    @safe_dishes_count = Dish.safe.count

    restriction_counts = Dish
      .includes(ingredients: :restrictions, elaborations: { ingredients: :restrictions })
      .map { |dish| dish.all_restrictions.size }
    tally = restriction_counts.tally
    max_count = tally.keys.max || 0
    @dishes_by_restriction_count = (0..max_count).index_with { |n| tally[n] || 0 }

    @restrictions_by_type = Restriction.restriction_types.keys.map do |type|
      restriction_ids = Restriction.where(restriction_type: type).ids
      dishes_count = restriction_ids.any? ? Dish
        .joins(ingredients: :ingredient_restrictions)
        .where(ingredient_restrictions: { restriction_id: restriction_ids })
        .distinct
        .count : 0
      { type: type, dishes_count: dishes_count }
    end
  end
end
