class DishesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!, except: %i[ index show ]
  before_action :set_dish, only: [ :show, :edit, :update, :destroy ]

  def index
    @dishes = Dish
      .search(params[:search])
      .of_types(params[:dish_types])
      .with_restrictions(params[:include_restrictions])
      .without_restrictions(params[:exclude_restrictions])
      .includes(ingredients: :restrictions)
      .order(name: :asc)
    @dish_types = Dish.dish_types.keys
    @restrictions = Restriction.order(:name)
  end

  def show
  end

  def new
    @dish = Dish.new
    @ingredients = Ingredient.all
    @elaborations = Elaboration.order(:name)
  end

  def edit
    @ingredients = Ingredient.all
    @elaborations = Elaboration.order(:name)
  end

  def create
    @dish = Dish.new(dish_params)

    if @dish.save
      redirect_to @dish, notice: t("dishes.messages.created_success")
    else
      @ingredients = Ingredient.all
      @elaborations = Elaboration.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @dish.update(dish_params)
      redirect_to @dish, notice: t("dishes.messages.updated_success")
    else
      @ingredients = Ingredient.all
      @elaborations = Elaboration.order(:name)
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
    params.require(:dish).permit(:name, :description, :dish_type, ingredient_ids: [], elaboration_ids: [])
  end
end
