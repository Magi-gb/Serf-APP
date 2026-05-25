class DishesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!, except: %i[ index show ]
  before_action :set_dish, only: [ :show, :edit, :update, :destroy ]

  def index
    @dishes = Dish.search(params[:search]).order(name: :asc)
  end

  def show
  end

  def new
    @dish = Dish.new
    @ingredients = Ingredient.all
  end

  def edit
    @ingredients = Ingredient.all
  end

  def create
    @dish = Dish.new(dish_params)

    if @dish.save
      redirect_to @dish, notice: t("dishes.messages.created_success")
    else
      @ingredients = Ingredient.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @dish.update(dish_params)
      redirect_to @dish, notice: t("dishes.messages.updated_success")
    else
      @ingredients = Ingredient.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dish.destroy
    redirect_to dishes_url, notice: t("dishes.messages.destroyed_success")
  end

  private

  def set_dish
    @dish = Dish.find(params[:id])
  end

  def dish_params
    params.require(:dish).permit(:name, :description, :dish_type, ingredient_ids: [])
  end
end
