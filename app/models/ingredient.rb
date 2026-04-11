class Ingredient < ApplicationRecord
  has_many :ingredient_restrictions, dependent: :destroy
  has_many :restrictions, through: :ingredient_restrictions

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
