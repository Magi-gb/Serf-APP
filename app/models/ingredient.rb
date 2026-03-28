class Ingredient < ApplicationRecord
  has_many :ingredient_restriccios
  has_many :restriccions, through: :ingredient_restriccios
end

