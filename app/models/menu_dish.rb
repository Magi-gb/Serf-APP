class MenuDish < ApplicationRecord
  belongs_to :menu
  belongs_to :dish

  validates :menu_id, uniqueness: { scope: :dish_id }
end
