class Menu < ApplicationRecord
  DISH_TYPES = %w[starter main dessert].freeze

  before_validation :normalize_attributes

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end
end
