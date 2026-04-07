class IngredientRestriction < ApplicationRecord
  belongs_to :ingredient
  belongs_to :restriction
end
