User.find_or_create_by!(username: "admin") do |u|
  u.password = "password"
  u.role = :admin
end
