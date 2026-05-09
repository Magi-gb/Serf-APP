class MenuPlat < ApplicationRecord
  belongs_to :menu
  belongs_to :plat

  validates :menu_id, uniqueness: { scope: :plat_id }
end
