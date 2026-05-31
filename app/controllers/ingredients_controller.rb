class IngredientsController < ApplicationController
  before_action :set_ingredient, only: [ :show, :edit, :update, :destroy ]
  before_action :require_kitchen_manager_or_above!, except: %i[index show]

  def index
    @ingredients = Ingredient.search(params[:search])
    @ingredients = if params[:safe_only].present?
      @ingredients.safe
    else
      @ingredients.with_restrictions(params[:include_restrictions]).without_restrictions(params[:exclude_restrictions])
    end
    @ingredients = @ingredients.order(:name)
    @restrictions = Restriction.order(:name)
  end

  def show
    # Eager-load so the "used in dishes" list can render each dish's
    # restriction tags without an N+1 over ingredients/restrictions.
    @dishes = @ingredient.dishes.includes(ingredients: :restrictions).order(:name).to_a
  end

  def new
    @ingredient = Ingredient.new
    @restrictions = Restriction.order(:name)
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)

    if @ingredient.save
      redirect_to ingredients_path, notice: t("ingredients.create.success")
    else
      @restrictions = Restriction.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @restrictions = Restriction.order(:name)
  end

  def update
    if @ingredient.update(ingredient_params)
      redirect_to ingredients_path, notice: t("ingredients.update.success")
    else
      @restrictions = Restriction.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ingredient.destroy
    redirect_to ingredients_path, notice: t("ingredients.destroy.success")
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end

  def ingredient_params
    params.require(:ingredient).permit(:name, :description, restriction_ids: [])
  end
end
