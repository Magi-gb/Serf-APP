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

# --- Ingredients ---

ingredients_data = [
  { name: "Farina de blat", description: "Farina procedent del blat, base de pa i pasta.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Llet sencera", description: "Llet de vaca sencera pasteuritzada.", restrictions: [ "Llet" ] },
  { name: "Ou de gallina", description: "Ou fresc de gallina.", restrictions: [ "Ous" ] },
  { name: "Gamba", description: "Gamba fresca de la Mediterrània.", restrictions: [ "Crustacis" ] },
  { name: "Soja texturitzada", description: "Proteïna de soja texturitzada.", restrictions: [ "Soja" ] },
  { name: "Cacauet torrat", description: "Cacauets torrats sense sal.", restrictions: [ "Cacauets" ] },
  { name: "Salmó fresc", description: "Filet de salmó fresc.", restrictions: [ "Peix" ] },
  { name: "Ametlla", description: "Ametlla crua sense pell.", restrictions: [ "Fruits de closca" ] },
  { name: "Salsa de mostassa", description: "Mostassa de Dijon.", restrictions: [ "Mostassa" ] },
  { name: "Pa de sèsam", description: "Pa elaborat amb grans de sèsam.", restrictions: [ "Gluten (Cereals)", "Sèsam" ] },
  { name: "Tomàquet", description: "Tomàquet madur de temporada.", restrictions: [] },
  { name: "Oli d'oliva", description: "Oli d'oliva verge extra.", restrictions: [] }
]

ingredients_data.each do |data|
  ingredient = Ingredient.find_or_create_by!(name: data[:name]) do |i|
    i.description = data[:description]
  end

  data[:restrictions].each do |restriction_name|
    restriction = Restriction.find_by!(name: restriction_name)
    IngredientRestriction.find_or_create_by!(ingredient: ingredient, restriction: restriction)
  end
end
