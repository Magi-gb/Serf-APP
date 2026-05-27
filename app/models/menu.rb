class Menu < ApplicationRecord
  REQUIRED_DISH_TYPES = %w[entrant primer segon postre].freeze

  has_many :menu_dishes, dependent: :destroy
  has_many :dishes, through: :menu_dishes

  before_validation :normalize_attributes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :must_have_one_dish_of_each_type

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }
  scope :without_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    where.not(
      id: joins(dishes: { ingredients: :ingredient_restrictions })
            .where(ingredient_restrictions: { restriction_id: ids })
            .select("menus.id")
    )
  }

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end

  def must_have_one_dish_of_each_type
    return if persisted? && dishes.empty?

    dishes_by_type = dishes.group_by(&:dish_type)

    REQUIRED_DISH_TYPES.each do |type|
      count = dishes_by_type[type]&.length || 0
      if count == 0
        errors.add(:base, I18n.t("menus.errors.missing_dish_type", type:))
      end
    end
  end
end
