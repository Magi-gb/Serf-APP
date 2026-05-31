class StatisticsController < ApplicationController
  before_action :require_admin!

  def index
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
    end

    @total_dishes_count = Dish.count
    @safe_dishes_count = Dish
      .left_joins(ingredients: :ingredient_restrictions)
      .where(ingredient_restrictions: { id: nil })
      .distinct
      .count

    raw_type_counts = Dish.group(:dish_type).count
    @dish_type_counts = Dish.dish_types.keys.index_with { |type| raw_type_counts[type] || 0 }

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
