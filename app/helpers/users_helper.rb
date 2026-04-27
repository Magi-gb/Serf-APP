module UsersHelper
  AVATAR_COLORS = %w[#3a5dae #e6222e #f5c518 #2e7d32 #6a1b9a #c62828 #00838f #ef6c00].freeze

  def user_avatar_color(user)
    AVATAR_COLORS[user.username.bytes.sum % AVATAR_COLORS.length]
  end
end
