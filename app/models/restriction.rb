class Restriction < ApplicationRecord
  enum :restriction_type, { intolerance_allergy: 0, religious: 1 }

  has_many :ingredient_restrictions, dependent: :destroy
  has_many :ingredients, through: :ingredient_restrictions

  validates :name, presence: true, uniqueness: true
  validates :restriction_type, presence: true
end
