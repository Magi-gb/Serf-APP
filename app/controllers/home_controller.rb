class HomeController < ApplicationController
  include LoadsStatistics

  def index
    @dish_count = Dish.count
    @menu_count = Menu.count
    @restriction_count = Restriction.count
    load_statistics
  end
end
