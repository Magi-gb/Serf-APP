class MenuPlat < ApplicationRecord
  belongs_to :menu
  belongs_to :plat

  validates :plat_id, presence: true
end
