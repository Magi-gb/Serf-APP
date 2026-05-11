class Ingredient < ApplicationRecord
  has_many :ingredient_restrictions, dependent: :destroy
  has_many :restrictions, through: :ingredient_restrictions
  has_many :dish_ingredients, dependent: :destroy
  has_many :dishes, through: :dish_ingredients

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }

  validates :name, presence: true, uniqueness: true
end
