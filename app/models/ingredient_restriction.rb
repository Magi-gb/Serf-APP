class IngredientRestriction < ApplicationRecord
  belongs_to :ingredient
  belongs_to :restriction

  validates :ingredient_id, uniqueness: { scope: :restriction_id }
end
