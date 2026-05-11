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

# Create menus
menu_setmanal = Menu.find_or_create_by!(name: "Menú setmanal")
menu_degustacio = Menu.find_or_create_by!(name: "Menú degustació")
menu_infantil = Menu.find_or_create_by!(name: "Menú infantil")

# --- Entrantes ---
entrant_pa = Plat.find_or_create_by!(name: "Pa amb tomàquet") do |p|
  p.description = "Pa torrat amb tomàquet i oli d'oliva verge"
  p.tipusPlat = :entrant
end

entrant_olivas = Plat.find_or_create_by!(name: "Olivas variades") do |p|
  p.description = "Olives de diverses varietats amb herbes aromàtiques"
  p.tipusPlat = :entrant
end

entrant_jamó = Plat.find_or_create_by!(name: "Jamó ibèric") do |p|
  p.description = "Talls de jamó ibèric de qualitat superior"
  p.tipusPlat = :entrant
end

entrant_amanida = Plat.find_or_create_by!(name: "Amanida fresca") do |p|
  p.description = "Amanida variada amb verdures de temporada"
  p.tipusPlat = :entrant
end

# --- Primers (plats de pasta, arròs, etc.) ---
primer_paella = Plat.find_or_create_by!(name: "Paella de marisco") do |p|
  p.description = "Paella amb gamba, musclo i altres mariscos"
  p.tipusPlat = :primer
end

primer_macarrons = Plat.find_or_create_by!(name: "Macarrons a la carbonara") do |p|
  p.description = "Pasta amb salsa carbonara clàssica"
  p.tipusPlat = :primer
end

primer_arros = Plat.find_or_create_by!(name: "Arròs a banda") do |p|
  p.description = "Arròs cuinat amb brou de peix i verdures"
  p.tipusPlat = :primer
end

primer_canelons = Plat.find_or_create_by!(name: "Canelons de carn") do |p|
  p.description = "Canelons rellens de carn amb salsa de tomaquet"
  p.tipusPlat = :primer
end

primer_espaguetis = Plat.find_or_create_by!(name: "Espaguetis a la bolomesa") do |p|
  p.description = "Espaguetis amb salsa de carn picada"
  p.tipusPlat = :primer
end

# --- Segons (peixos, carns, etc.) ---
segon_salmó = Plat.find_or_create_by!(name: "Salmó a la sal") do |p|
  p.description = "Filet de salmó cuinat a la sal amb herbes"
  p.tipusPlat = :segon
end

segon_pollastre = Plat.find_or_create_by!(name: "Pollastre al forn") do |p|
  p.description = "Pollastre rostit amb herbes aromàtiques i patates"
  p.tipusPlat = :segon
end

segon_truita = Plat.find_or_create_by!(name: "Truita a la meunière") do |p|
  p.description = "Truita fresca amb salsa de mantega i llimona"
  p.tipusPlat = :segon
end

segon_vedella = Plat.find_or_create_by!(name: "Vedella amb salsa de setas") do |p|
  p.description = "Carn de vedella cuinada amb setes i vi tinto"
  p.tipusPlat = :segon
end

segon_estofat = Plat.find_or_create_by!(name: "Estofat de porc") do |p|
  p.description = "Porc estofat amb verdures i jugo de cocció"
  p.tipusPlat = :segon
end

segon_merluça = Plat.find_or_create_by!(name: "Merluça al vapor") do |p|
  p.description = "Merluça fresca al vapor amb verduretes"
  p.tipusPlat = :segon
end

# --- Postres ---
postre_gelat = Plat.find_or_create_by!(name: "Gelat artesanal") do |p|
  p.description = "Gelat casolà amb sabors variats: vainella, xocolata, pistacho"
  p.tipusPlat = :postre
end

postre_flan = Plat.find_or_create_by!(name: "Flà tradicional") do |p|
  p.description = "Flà clàssic amb caramel crematosquè"
  p.tipusPlat = :postre
end

postre_tiramisú = Plat.find_or_create_by!(name: "Tiramisú") do |p|
  p.description = "Postre italià amb mascarpone i cacao"
  p.tipusPlat = :postre
end

postre_brownie = Plat.find_or_create_by!(name: "Brownie de xocolata") do |p|
  p.description = "Brownie casolà amb xocolata fon al centre"
  p.tipusPlat = :postre
end

postre_panna_cotta = Plat.find_or_create_by!(name: "Panna cotta") do |p|
  p.description = "Panna cotta amb salsa de fruites del bosc"
  p.tipusPlat = :postre
end

postre_tarta_formatge = Plat.find_or_create_by!(name: "Tarta de formatge") do |p|
  p.description = "Tarta de formatge amb base de galetes"
  p.tipusPlat = :postre
end

# Associate dishes with menus (each menu needs at least one dish from each type)
MenuPlat.find_or_create_by!(menu: menu_setmanal, plat: entrant_pa)
MenuPlat.find_or_create_by!(menu: menu_setmanal, plat: primer_paella)
MenuPlat.find_or_create_by!(menu: menu_setmanal, plat: segon_salmó)
MenuPlat.find_or_create_by!(menu: menu_setmanal, plat: postre_gelat)

MenuPlat.find_or_create_by!(menu: menu_degustacio, plat: entrant_olivas)
MenuPlat.find_or_create_by!(menu: menu_degustacio, plat: primer_macarrons)
MenuPlat.find_or_create_by!(menu: menu_degustacio, plat: segon_pollastre)
MenuPlat.find_or_create_by!(menu: menu_degustacio, plat: postre_flan)

MenuPlat.find_or_create_by!(menu: menu_infantil, plat: entrant_pa)
MenuPlat.find_or_create_by!(menu: menu_infantil, plat: primer_macarrons)
MenuPlat.find_or_create_by!(menu: menu_infantil, plat: segon_pollastre)
MenuPlat.find_or_create_by!(menu: menu_infantil, plat: postre_gelat)

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
  { name: "Protocol de Contaminació Creuada", description: "Mesures estrictes per evitar la contaminació creuada amb al·lèrgens a la cuina.", bg_color: "#E74C3C" },
  { name: "Protocol de Neteja", description: "Passos a seguir per la neteja d'estris abans de preparar plats per celíacs.", bg_color: "#3498DB" },
  { name: "Protocol d'Emergència Mèdica", description: "Procediment d'actuació ràpida en cas d'un xoc anafilàctic.", bg_color: "#E67E22" }
]

protocols_data.each do |data|
  Protocol.find_or_create_by!(name: data[:name]) do |p|
    p.description = data[:description]
    p.bg_color = data[:bg_color]
  end
end
