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
    via_ingredients = joins(dishes: { ingredients: :ingredient_restrictions })
                        .where(ingredient_restrictions: { restriction_id: ids })
                        .select(:id)
    via_elaborations = joins(dishes: { elaborations: { ingredients: :ingredient_restrictions } })
                         .where(ingredient_restrictions: { restriction_id: ids })
                         .select(:id)
    where(id: via_ingredients).or(where(id: via_elaborations))
  }
  scope :without_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    where.not(
      id: joins(dishes: { ingredients: :ingredient_restrictions })
            .where(ingredient_restrictions: { restriction_id: ids })
            .select(:id)
    ).where.not(
      id: joins(dishes: { elaborations: { ingredients: :ingredient_restrictions } })
            .where(ingredient_restrictions: { restriction_id: ids })
            .select(:id)
    )
  }
  scope :safe, -> {
    where.not(id: joins(dishes: { ingredients: :ingredient_restrictions }).select(:id))
      .where.not(id: joins(dishes: { elaborations: { ingredients: :ingredient_restrictions } }).select(:id))
  }

  # Restrictions affecting this menu, gathered from every dish (which in turn
  # combines its direct ingredients and its elaborations' ingredients),
  # deduplicated.
  def all_restrictions
    dishes.flat_map(&:all_restrictions).uniq
  end

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end

  def must_have_at_least_one_dish
    errors.add(:base, I18n.t("menus.errors.no_dishes")) if dishes.empty?
  end
end
