class Ingredient < ApplicationRecord
  has_many :ingredient_restriccios
  has_many :restriccions, through: :ingredient_restriccios

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end

