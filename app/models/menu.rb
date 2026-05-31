class Menu < ApplicationRecord
  has_many :menu_dishes, dependent: :destroy
  has_many :dishes, through: :menu_dishes

  before_validation :normalize_attributes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :must_have_at_least_one_dish

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }
  scope :with_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    joins(dishes: { ingredients: :ingredient_restrictions })
      .where(ingredient_restrictions: { restriction_id: ids })
      .distinct
  }
  scope :without_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    where.not(
      id: joins(dishes: { ingredients: :ingredient_restrictions })
            .where(ingredient_restrictions: { restriction_id: ids })
            .select(:id)
    )
  }
  scope :safe, -> {
    where.not(id: joins(dishes: { ingredients: :ingredient_restrictions }).select(:id))
  }

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end

  def must_have_at_least_one_dish
    errors.add(:base, I18n.t("menus.errors.no_dishes")) if dishes.empty?
  end
end
