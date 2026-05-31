class Restriction < ApplicationRecord
  enum :restriction_type, { intolerance_allergy: 0, diet: 1 }
  enum :severity, { low: 0, medium: 1, high: 2 }, default: :medium

  has_many :ingredient_restrictions, dependent: :destroy
  has_many :ingredients, through: :ingredient_restrictions

  validates :name, presence: true, uniqueness: true
  validates :restriction_type, presence: true
  validates :severity, presence: true

  # Default display order: allergies/intolerances (type 0) before diets (type 1),
  # then alphabetically by name within each type. Not a default_scope on purpose —
  # that would override the sortable restrictions catalog index.
  scope :ordered, -> { order(:restriction_type, :name) }

  def recalculate_all_cached_counts!
    direct_dish_ids = Dish.joins(ingredients: :ingredient_restrictions)
                          .where(ingredient_restrictions: { restriction_id: id })
                          .distinct.pluck(:id)
    elab_dish_ids   = Dish.joins(elaborations: { ingredients: :ingredient_restrictions })
                          .where(ingredient_restrictions: { restriction_id: id })
                          .distinct.pluck(:id)
    direct_menu_ids = Menu.joins(dishes: { ingredients: :ingredient_restrictions })
                          .where(ingredient_restrictions: { restriction_id: id })
                          .distinct.pluck(:id)
    elab_menu_ids   = Menu.joins(dishes: { elaborations: { ingredients: :ingredient_restrictions } })
                          .where(ingredient_restrictions: { restriction_id: id })
                          .distinct.pluck(:id)

    update_columns(
      ingredients_count: ingredient_restrictions.count,
      elaborations_count: Elaboration.joins(ingredients: :ingredient_restrictions)
                                     .where(ingredient_restrictions: { restriction_id: id })
                                     .distinct.count,
      dishes_count: (direct_dish_ids | elab_dish_ids).size,
      menus_count:  (direct_menu_ids | elab_menu_ids).size
    )
  end

  def self.recalculate_all_cached_counts!
    find_each(&:recalculate_all_cached_counts!)
  end
end
