class IngredientAlternative < ApplicationRecord
  belongs_to :ingredient
  belongs_to :alternative, class_name: "Ingredient"

  validates :alternative_id, uniqueness: { scope: :ingredient_id }
  validate :alternative_is_not_self
  validate :alternative_does_not_add_restrictions

  private

  def alternative_is_not_self
    return if ingredient_id.blank? || alternative_id.blank?

    errors.add(:alternative, :invalid) if ingredient_id == alternative_id
  end

  def alternative_does_not_add_restrictions
    return if ingredient.nil? || alternative.nil?

    extra_restriction_ids = alternative.restriction_ids - ingredient.restriction_ids
    return if extra_restriction_ids.empty?

    errors.add(:alternative, :cannot_add_restrictions)
  end
end
