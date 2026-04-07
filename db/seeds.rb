User.find_or_create_by!(username: "admin") do |u|
  u.password = "password"
  u.role = :admin
end

User.find_or_create_by!(username: "cuiner") do |u|
  u.password = "password"
  u.role = :kitchen_manager
end

User.find_or_create_by!(username: "cambrer") do |u|
  u.password = "password"
  u.role = :waiter
end

# 14 Allergens according to EU Regulation
eu_allergens = [
  "Gluten (Cereals)",
  "Llet",
  "Ous",
  "Peix",
  "Crustacis",
  "Mol·luscs",
  "Cacauets",
  "Fruits de closca",
  "Sèsam",
  "Celerí",
  "Mostassa",
  "Sulfits",
  "Altramús",
  "Soja"
]

eu_allergens.each do |allergen|
  Restriction.find_or_create_by!(name: allergen, restriction_type: :intolerance_allergy)
end

# Religious Restrictions
religious_restrictions = [
  "Halal",
  "Kosher",
  "Hindú",
  "Budista",
  "Vegà",
  "Vegetarià"
]

religious_restrictions.each do |restriction|
  Restriction.find_or_create_by!(name: restriction, restriction_type: :religious)
end

