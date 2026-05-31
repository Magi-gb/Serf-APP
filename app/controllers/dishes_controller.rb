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
    @ingredients = Ingredient.includes(:restrictions).order(:name)
    @elaborations = Elaboration.order(:name)
    @dish_essential_ingredient_ids = []
  end

  def edit
    @ingredients = Ingredient.includes(:restrictions).order(:name)
    @elaborations = Elaboration.order(:name)
    @dish_essential_ingredient_ids = @dish.dish_ingredients.where(essential: true).pluck(:ingredient_id)
  end

  def create
    @dish = Dish.new(dish_params)
    substituible_ids = extract_substituible_ingredient_ids

    if @dish.save
      apply_essential_flags(@dish, substituible_ids)
      redirect_to @dish, notice: t("dishes.messages.created_success")
    else
      @ingredients = Ingredient.includes(:restrictions).order(:name)
      @elaborations = Elaboration.order(:name)
      @dish_essential_ingredient_ids = @dish.ingredient_ids - substituible_ids
      render :new, status: :unprocessable_entity
    end
  end

  def update
    substituible_ids = extract_substituible_ingredient_ids

    if @dish.update(dish_params)
      apply_essential_flags(@dish, substituible_ids)
      redirect_to @dish, notice: t("dishes.messages.updated_success")
    else
      @ingredients = Ingredient.includes(:restrictions).order(:name)
      @elaborations = Elaboration.order(:name)
      @dish_essential_ingredient_ids = @dish.ingredient_ids - substituible_ids
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dish.destroy
    redirect_to dishes_url, notice: t("dishes.messages.destroyed_success")
  end

  private

  def set_dish
    @dish = Dish.includes(dish_ingredients: :ingredient, ingredients: :restrictions).find(params[:id])
  end

  def dish_params
    params.require(:dish).permit(:name, :description, :dish_type, ingredient_ids: [], elaboration_ids: [])
  end

  def extract_substituible_ingredient_ids
    (params.dig(:dish, :substituible_ingredient_ids) || []).map(&:to_i)
  end

  def apply_essential_flags(dish, substituible_ids)
    dish.dish_ingredients.each do |di|
      di.update!(essential: !substituible_ids.include?(di.ingredient_id))
    end
  end
end
