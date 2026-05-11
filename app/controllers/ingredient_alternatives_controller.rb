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

  # Bulk-update the alternatives set in one submission (used by the
  # searchable-checkbox picker on the show page). Wraps add/remove in a
  # transaction so the set either applies fully or not at all.
  def update_collection
    raw = Array(params.permit(alternative_ids: [])[:alternative_ids])
    desired_ids = raw.compact_blank.map(&:to_i)
    current_ids = @ingredient.alternative_ids

    IngredientAlternative.transaction do
      (current_ids - desired_ids).each do |gone|
        @ingredient.ingredient_alternatives.find_by(alternative_id: gone)&.destroy!
      end
      (desired_ids - current_ids).each do |added|
        @ingredient.ingredient_alternatives.create!(alternative_id: added)
      end
    end

    redirect_to ingredient_path(@ingredient), notice: t(".success")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to ingredient_path(@ingredient), alert: e.message
  end

  private

  # Member-level routes (update_collection) carry the parent id in :id,
  # nested routes (create / destroy) carry it in :ingredient_id.
  def set_ingredient
    @ingredient = Ingredient.find(params[:ingredient_id] || params[:id])
  end

  def ingredient_alternative_params
    params.require(:ingredient_alternative).permit(:alternative_id)
  end
end
