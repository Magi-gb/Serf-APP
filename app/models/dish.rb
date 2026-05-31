class Dish < ApplicationRecord
  has_many :menu_dishes, dependent: :destroy
  has_many :menus, through: :menu_dishes
  has_many :dish_ingredients, dependent: :destroy
  has_many :ingredients, through: :dish_ingredients

  before_validation :normalize_attributes

  validates :name, presence: true
  validates :description, presence: true
  enum :dish_type, { entrant: 0, primer: 1, segon: 2, postre: 3 }

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }
  scope :of_types, ->(types) {
    types = Array(types).compact_blank
    next all if types.empty?
    where(dish_type: types)
  }
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

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end
end
