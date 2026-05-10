class Menu < ApplicationRecord
  DISH_TYPES = %w[starter main dessert].freeze

  has_many :menu_plats, dependent: :destroy
  has_many :plats, through: :menu_plats

  before_validation :normalize_attributes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end
end
