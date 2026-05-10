class Plat < ApplicationRecord
  has_many :menu_plats, dependent: :destroy
  has_many :menus, through: :menu_plats
  has_many :plat_ingredients, dependent: :destroy
  has_many :ingredients, through: :plat_ingredients
  has_many :menu_plats, dependent: :destroy
  has_many :menus, through: :menu_plats

  validates :name, presence: true
  validates :description, presence: true
  validates :tipusPlat, presence: true
  enum tipusPlat: {
  entrant: 0,
  primer: 1,
  segon: 2,
  postre: 3
}
end
