class Ingredient < ApplicationRecord
  has_many :ingredient_restrictions, dependent: :destroy
  has_many :restrictions, through: :ingredient_restrictions
  has_many :dish_ingredients, dependent: :destroy
  has_many :dishes, through: :dish_ingredients
  has_many :elaboration_ingredients, dependent: :destroy
  has_many :elaborations, through: :elaboration_ingredients

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }
  scope :with_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    joins(:ingredient_restrictions).where(ingredient_restrictions: { restriction_id: ids }).distinct
  }
  scope :without_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    where.not(id: joins(:ingredient_restrictions).where(ingredient_restrictions: { restriction_id: ids }).select(:ingredient_id))
  }

  validates :name, presence: true, uniqueness: true
end
