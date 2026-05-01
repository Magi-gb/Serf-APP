class IngredientAlternativesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!
  before_action :set_ingredient

  def create
    ingredient_alternative = @ingredient.ingredient_alternatives.new(ingredient_alternative_params)

    if ingredient_alternative.save
      redirect_to ingredient_path(@ingredient), notice: t(".success")
    else
      redirect_to ingredient_path(@ingredient), alert: ingredient_alternative.errors.full_messages.to_sentence
    end
  end

  def destroy
    ingredient_alternative = @ingredient.ingredient_alternatives.find_by!(alternative_id: params[:id])
    ingredient_alternative.destroy!

    redirect_to ingredient_path(@ingredient), notice: t(".success"), status: :see_other
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:ingredient_id])
  end

  def ingredient_alternative_params
    params.require(:ingredient_alternative).permit(:alternative_id)
  end
end
