class Plat < ApplicationRecord
  has_many :plat_ingredients, dependent: :destroy
  has_many :ingredients, through: :plat_ingredients

  validates :name, presence: true
  validates :description, presence: true
end

