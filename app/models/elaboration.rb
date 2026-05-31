class Elaboration < ApplicationRecord
  has_many :elaboration_ingredients, dependent: :destroy
  has_many :ingredients, through: :elaboration_ingredients
  has_many :dish_elaborations, dependent: :destroy
  has_many :dishes, through: :dish_elaborations

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }
  scope :with_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    joins(ingredients: :ingredient_restrictions)
      .where(ingredient_restrictions: { restriction_id: ids })
      .distinct
  }
  scope :without_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    where.not(
      id: joins(ingredients: :ingredient_restrictions)
            .where(ingredient_restrictions: { restriction_id: ids })
            .select(:id)
    )
  }
  scope :safe, -> {
    where.not(id: joins(ingredients: :ingredient_restrictions).select(:id))
  }

  validates :name, presence: true, uniqueness: true

  def restrictions
    ingredients.flat_map(&:restrictions).uniq
  end
end
