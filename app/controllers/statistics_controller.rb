class StatisticsController < ApplicationController
  def index
    @statistics = Restriction.order(:name).map do |restriction|
      {
        restriction: restriction,
        compatible_dishes: Dish.without_restrictions([ restriction.id ]).count,
        compatible_menus: Menu.without_restrictions([ restriction.id ]).count
      }
    end
  end
end