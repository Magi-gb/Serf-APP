class Restriction < ApplicationRecord
  enum :restriction_type, { intolerance_allergy: 0, diet: 1 }
  enum :severity, { low: 0, medium: 1, high: 2 }, default: :medium

  has_many :ingredient_restrictions, dependent: :destroy
  has_many :ingredients, through: :ingredient_restrictions

  validates :name, presence: true, uniqueness: true
  validates :restriction_type, presence: true
  validates :severity, presence: true
end
