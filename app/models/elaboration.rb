class Elaboration < ApplicationRecord
  has_many :elaboration_ingredients, dependent: :destroy
  has_many :ingredients, through: :elaboration_ingredients
  has_many :dish_elaborations, dependent: :destroy
  has_many :dishes, through: :dish_elaborations

  scope :search, ->(query) { query.present? ? where("name LIKE ?", "%#{query}%") : all }

  validates :name, presence: true, uniqueness: true

  def restrictions
    ingredients.flat_map(&:restrictions).uniq
  end
end
