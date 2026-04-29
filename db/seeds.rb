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
  { name: "Gluten (Cereals)", desc: "Cereals que continguin gluten i productes derivats.", bg_color: "#E67E22" },
  { name: "Llet", desc: "Llet i els seus derivats (inclosa la lactosa).", bg_color: "#3498DB" },
  { name: "Ous", desc: "Ous i productes a base d'ou.", bg_color: "#F1C40F" },
  { name: "Peix", desc: "Peix i productes a base de peix.", bg_color: "#1ABC9C" },
  { name: "Crustacis", desc: "Crustacis i productes a base de crustacis.", bg_color: "#E74C3C" },
  { name: "Mol·luscs", desc: "Mol·luscs i productes a base de mol·luscs.", bg_color: "#2C3E50" },
  { name: "Cacauets", desc: "Cacauets i productes a base de cacauets.", bg_color: "#8E44AD" },
  { name: "Fruits de closca", desc: "Ametlles, avellanes, nous, anacards, festucs i derivats.", bg_color: "#D35400" },
  { name: "Sèsam", desc: "Grans de sèsam i productes a base de sèsam.", bg_color: "#95A5A6" },
  { name: "Celerí", desc: "Api i productes derivats.", bg_color: "#27AE60" },
  { name: "Mostassa", desc: "Mostassa i productes derivats.", bg_color: "#F39C12" },
  { name: "Sulfits", desc: "Diòxid de sofre i sulfits (> 10 mg/kg o 10 mg/l SO2).", bg_color: "#7F8C8D" },
  { name: "Altramús", desc: "Tramussos i productes a base de tramussos.", bg_color: "#F1C40F" },
  { name: "Soja", desc: "Soja i productes a base de soja.", bg_color: "#2ECC71" }
]

eu_allergens.each do |allergen|
  Restriction.find_or_create_by!(name: allergen[:name]) do |r|
    r.restriction_type = :intolerance_allergy
    r.description = allergen[:desc]
    r.bg_color = allergen[:bg_color]
  end
end

# Religious Restrictions
religious_restrictions = [
  { name: "Halal", desc: "Requisits alimentaris islàmics.", bg_color: "#16A085" },
  { name: "Kosher", desc: "Requisits alimentaris jueus.", bg_color: "#2980B9" },
  { name: "Hindú", desc: "Restriccions alimentàries hinduistes.", bg_color: "#E67E22" },
  { name: "Budista", desc: "Restriccions alimentàries budistes.", bg_color: "#F39C12" },
  { name: "Vegà", desc: "Sense cap producte d'origen animal.", bg_color: "#27AE60" },
  { name: "Vegetarià", desc: "Sense carn ni peix.", bg_color: "#2ECC71" }
]

religious_restrictions.each do |restriction|
  Restriction.find_or_create_by!(name: restriction[:name]) do |r|
    r.restriction_type = :religious
    r.description = restriction[:desc]
    r.bg_color = restriction[:bg_color]
  end
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

# --- Protocols ---

protocols_data = [
  { name: "Protocol de Contaminació Creuada", description: "Mesures estrictes per evitar la contaminació creuada amb al·lèrgens a la cuina." },
  { name: "Protocol de Neteja", description: "Passos a seguir per la neteja d'estris abans de preparar plats per celíacs." },
  { name: "Protocol d'Emergència Mèdica", description: "Procediment d'actuació ràpida en cas d'un xoc anafilàctic." }
]

protocols_data.each do |data|
  Protocol.find_or_create_by!(name: data[:name]) do |p|
    p.description = data[:description]
  end
end
