class Protocol < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
