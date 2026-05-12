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
  scope :filter_by_types, ->(types) { types.present? ? where(dish_type: types) : all }
  scope :filter_by_restrictions, lambda { |include_ids, exclude_ids|
    include_ids = Array(include_ids).map(&:to_s).compact
    exclude_ids = Array(exclude_ids).map(&:to_s).compact

    result = all
    result = result.joins(ingredients: :restrictions)
                   .where(restrictions: { id: include_ids })
                   .distinct if include_ids.any?

    result = result.where.not(id: Dish.joins(ingredients: :restrictions)
                                      .where(restrictions: { id: exclude_ids })
                                      .select(:id)) if exclude_ids.any?

    result
  }

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end
end
