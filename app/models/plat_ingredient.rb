class PlatIngredient < ApplicationRecord
  belongs_to :plat
  belongs_to :ingredient

  validates :plat_id, uniqueness: { scope: :ingredient_id }
end
