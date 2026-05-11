class HomeController < ApplicationController
  def index
    @dish_count = Dish.count
    @menu_count = Menu.count
    @restriction_count = Restriction.count
    @user_count = User.count
  end
end
