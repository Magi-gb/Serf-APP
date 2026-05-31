class Restriction < ApplicationRecord
  enum :restriction_type, { intolerance_allergy: 0, diet: 1, preference: 2 }

  has_many :ingredient_restrictions, dependent: :destroy
  has_many :ingredients, through: :ingredient_restrictions

  validates :name, presence: true, uniqueness: true
  validates :restriction_type, presence: true
end
