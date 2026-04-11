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

# Funció per crear un SVG vectoritzat de farcit mentrestant es pugen els finals
def vector_icon(emoji)
  %(<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><text x="50" y="55" font-size="50" text-anchor="middle" dominant-baseline="central">#{emoji}</text></svg>)
end

allergens = [
  { name: "Gluten", desc: "Cereals que continguin gluten (brot, sègol, ordi, civada, espelta, kamut o les seves varietats híbrides) i productes derivats.", bg_color: "#E67E22", icon: "🌾" },
  { name: "Crustacis", desc: "Crustacis i productes a base de crustacis.", bg_color: "#E74C3C", icon: "🦐" },
  { name: "Ous", desc: "Ous i productes a base d'ou.", bg_color: "#F1C40F", icon: "🥚" },
  { name: "Peix", desc: "Peix i productes a base de peix.", bg_color: "#3498DB", icon: "🐟" },
  { name: "Cacauets", desc: "Cacauets i productes a base de cacauets.", bg_color: "#8E44AD", icon: "🥜" },
  { name: "Soja", desc: "Soja i productes a base de soja.", bg_color: "#2ECC71", icon: "🌱" },
  { name: "Lactis", desc: "Llet i els seus derivats (inclosa la lactosa).", bg_color: "#3498DB", icon: "🥛" },
  { name: "Fruits de pela", desc: "Ametlles, avellanes, nous, anacards, pacanes, nous del Brasil, festucs, nous macadàmia i derivats.", bg_color: "#D35400", icon: "🌰" },
  { name: "Api", desc: "Api i productes derivats.", bg_color: "#27AE60", icon: "🥬" },
  { name: "Mostassa", desc: "Mostassa i productes derivats.", bg_color: "#F39C12", icon: "🌭" },
  { name: "Sèsam", desc: "Grans de sèsam i productes a base de grans de sèsam.", bg_color: "#95A5A6", icon: "🥯" },
  { name: "Sulfits", desc: "Diòxid de sofre i sulfits en concentracions superiors a 10 mg/kg o 10 mg/litre en termes de SO2 total.", bg_color: "#7F8C8D", icon: "🍷" },
  { name: "Tramussos", desc: "Tramussos i productes a base de tramussos.", bg_color: "#F1C40F", icon: "🫘" },
  { name: "Mol·luscs", desc: "Mol·luscs i productes a base de mol·luscs.", bg_color: "#2C3E50", icon: "🦑" }
]

allergens.each do |allergen|
  Restriction.find_or_create_by!(name: allergen[:name]) do |r|
    r.description = allergen[:desc]
    r.bg_color = allergen[:bg_color]
    r.icon_svg = vector_icon(allergen[:icon])
  end
end

# --- Ingredients ---

ingredients_data = [
  { name: "Farina de blat", description: "Farina procedent del blat, base de pa i pasta.", restrictions: ["Gluten"] },
  { name: "Llet sencera", description: "Llet de vaca sencera pasteuritzada.", restrictions: ["Lactis"] },
  { name: "Ou de gallina", description: "Ou fresc de gallina.", restrictions: ["Ous"] },
  { name: "Gamba", description: "Gamba fresca de la Mediterrània.", restrictions: ["Crustacis"] },
  { name: "Soja texturitzada", description: "Proteïna de soja texturitzada.", restrictions: ["Soja"] },
  { name: "Cacauet torrat", description: "Cacauets torrats sense sal.", restrictions: ["Cacauets"] },
  { name: "Salmó fresc", description: "Filet de salmó fresc.", restrictions: ["Peix"] },
  { name: "Ametlla", description: "Ametlla crua sense pell.", restrictions: ["Fruits de pela"] },
  { name: "Salsa de mostassa", description: "Mostassa de Dijon.", restrictions: ["Mostassa"] },
  { name: "Pa de sèsam", description: "Pa elaborat amb grans de sèsam.", restrictions: ["Gluten", "Sèsam"] },
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
