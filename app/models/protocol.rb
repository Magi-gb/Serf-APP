class Protocol < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }
end
