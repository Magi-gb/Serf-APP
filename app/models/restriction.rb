class Restriction < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
