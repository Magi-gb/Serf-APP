class Menu < ApplicationRecord
  REQUIRED_PLAT_TYPES = %w[entrant primer segon postre].freeze

  has_many :menu_plats, dependent: :destroy
  has_many :plats, through: :menu_plats

  before_validation :normalize_attributes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :must_have_one_plat_of_each_type

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end

  def must_have_one_plat_of_each_type
    return if persisted? && plats.empty?

    plats_by_type = plats.group_by(&:tipusPlat)

    REQUIRED_PLAT_TYPES.each do |type|
      count = plats_by_type[type]&.length || 0
      if count == 0
        errors.add(:base, I18n.t("menus.errors.missing_plat_type", type:))
      end
    end
  end
end
