class IngredientAlternative < ApplicationRecord
  belongs_to :ingredient
  belongs_to :alternative, class_name: "Ingredient"

  validates :alternative_id, uniqueness: { scope: :ingredient_id }
  validate :alternative_is_not_self

  private

  def alternative_is_not_self
    return if ingredient_id.blank? || alternative_id.blank?

    errors.add(:alternative, :invalid) if ingredient_id == alternative_id
  end
end
