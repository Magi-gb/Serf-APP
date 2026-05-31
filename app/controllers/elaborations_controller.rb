class ElaborationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!, except: %i[index show]
  before_action :set_elaboration, only: %i[show edit update destroy]

  def index
    @elaborations = Elaboration
      .search(params[:search])
      .with_restrictions(params[:include_restrictions])
      .without_restrictions(params[:exclude_restrictions])
      .order(:name)
    @restrictions = Restriction.order(:name)
  end

  def show
    @dishes = @elaboration.dishes.includes(ingredients: :restrictions, elaborations: { ingredients: :restrictions }).order(:name).to_a
  end

  def new
    @elaboration = Elaboration.new
    @ingredients = Ingredient.order(:name)
  end

  def edit
    @ingredients = Ingredient.order(:name)
  end

  def create
    @elaboration = Elaboration.new(elaboration_params)

    if @elaboration.save
      redirect_to @elaboration, notice: t("elaborations.messages.created_success")
    else
      @ingredients = Ingredient.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @elaboration.update(elaboration_params)
      redirect_to @elaboration, notice: t("elaborations.messages.updated_success")
    else
      @ingredients = Ingredient.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @elaboration.destroy
    redirect_to elaborations_url, notice: t("elaborations.messages.destroyed_success")
  end

  private

  def set_elaboration
    @elaboration = Elaboration.find(params[:id])
  end

  def elaboration_params
    params.require(:elaboration).permit(:name, :description, ingredient_ids: [])
  end
end
