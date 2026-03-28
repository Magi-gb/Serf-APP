class Restriccio < ApplicationRecord
  has_many :ingredient_restriccios
  has_many :ingredients, through: :ingredient_restriccios
end
