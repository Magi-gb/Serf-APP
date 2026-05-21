class Preparation < ApplicationRecord
  belongs_to :dish, optional: true

  enum :difficulty, { easy: 0, medium: 1, hard: 2 }

  before_validation :normalize_attributes

  validates :name, presence: true, uniqueness: true
  validates :time_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :difficulty, presence: true

  private

  def normalize_attributes
    self.name = name.to_s.strip
  end
end
