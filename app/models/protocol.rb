class Protocol < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }
end
