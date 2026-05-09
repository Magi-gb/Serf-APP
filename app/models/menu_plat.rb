class MenuPlat < ApplicationRecord
  belongs_to :menu
  belongs_to :plat

  validates :menu_id, presence: true
  validates :plat_id, presence: true
end

