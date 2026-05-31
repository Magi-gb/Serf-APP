class Dish < ApplicationRecord
  IMAGE_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze
  MAX_IMAGE_SIZE = 5.megabytes

  has_many :menu_dishes, dependent: :destroy
  has_many :menus, through: :menu_dishes
  has_many :dish_ingredients, dependent: :destroy
  has_many :ingredients, through: :dish_ingredients
  has_many :dish_elaborations, dependent: :destroy
  has_many :elaborations, through: :dish_elaborations

  has_one_attached :image

  before_validation :normalize_attributes

  validates :name, presence: true
  # validates :description, presence: true
  validate :at_least_one_ingredient_or_elaboration
  validate :acceptable_image
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
    via_ingredients = joins(ingredients: :ingredient_restrictions)
                        .where(ingredient_restrictions: { restriction_id: ids })
                        .select(:id)
    via_elaborations = joins(elaborations: { ingredients: :ingredient_restrictions })
                         .where(ingredient_restrictions: { restriction_id: ids })
                         .select(:id)
    where(id: via_ingredients).or(where(id: via_elaborations))
  }
  scope :without_restrictions, ->(ids) {
    ids = Array(ids).compact_blank
    next all if ids.empty?
    where.not(
      id: joins(ingredients: :ingredient_restrictions)
            .where(ingredient_restrictions: { restriction_id: ids })
            .select(:id)
    ).where.not(
      id: joins(elaborations: { ingredients: :ingredient_restrictions })
            .where(ingredient_restrictions: { restriction_id: ids })
            .select(:id)
    )
  }
  scope :safe, -> {
    where.not(id: joins(ingredients: :ingredient_restrictions).select(:id))
      .where.not(id: joins(elaborations: { ingredients: :ingredient_restrictions }).select(:id))
  }

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end

  def at_least_one_ingredient_or_elaboration
    errors.add(:ingredients, :blank) if ingredients.empty? && elaborations.empty?
  end

  def acceptable_image
    return unless image.attached?

    unless IMAGE_CONTENT_TYPES.include?(image.blob.content_type)
      errors.add(:image, :invalid_content_type)
    end

    if image.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, :too_large, max: MAX_IMAGE_SIZE / 1.megabyte)
    end
  end
end
