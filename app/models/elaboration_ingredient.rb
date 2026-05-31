class ElaborationIngredient < ApplicationRecord
  belongs_to :elaboration
  belongs_to :ingredient
end
