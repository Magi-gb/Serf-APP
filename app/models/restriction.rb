class Restriction < ApplicationRecord
  has_many :ingredient_restrictions, dependent: :destroy
  has_many :ingredients, through: :ingredient_restrictions

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
