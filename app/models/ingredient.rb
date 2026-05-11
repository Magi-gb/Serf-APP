class Ingredient < ApplicationRecord
  has_many :ingredient_restrictions, dependent: :destroy
  has_many :restrictions, through: :ingredient_restrictions
  has_many :plat_ingredients, dependent: :destroy
  has_many :plats, through: :plat_ingredients

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }

  validates :name, presence: true, uniqueness: true
end
