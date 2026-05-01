class Ingredient < ApplicationRecord
  has_many :ingredient_restrictions, dependent: :destroy
  has_many :restrictions, through: :ingredient_restrictions

  has_many :ingredient_alternatives, dependent: :destroy
  has_many :alternatives, through: :ingredient_alternatives, source: :alternative

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }

  validates :name, presence: true, uniqueness: true
end
