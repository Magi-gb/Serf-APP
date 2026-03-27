class User < ApplicationRecord
  devise :database_authenticatable

  enum :role, { waiter: 0, kitchen_manager: 1, admin: 2 }

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :role, presence: true

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
