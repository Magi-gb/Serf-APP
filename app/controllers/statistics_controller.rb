class StatisticsController < ApplicationController
  before_action :require_admin!

  def index
    @restrictions_stats = Restriction.includes(ingredients: :dishes).map do |restriction|
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
  end
end