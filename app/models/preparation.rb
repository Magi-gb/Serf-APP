class Preparation < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
