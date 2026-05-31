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

def emoji_icon(emoji)
  %(<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><text x="50" y="55" font-size="60" text-anchor="middle" dominant-baseline="central">#{emoji}</text></svg>)
end

eu_allergens = [
  { name: "Gluten (Cereals)", desc: "Cereals que continguin gluten i productes derivats.", bg_color: "#E67E22", emoji: "🌾" },
  { name: "Llet", desc: "Llet i els seus derivats (inclosa la lactosa).", bg_color: "#3498DB", emoji: "🥛" },
  { name: "Ous", desc: "Ous i productes a base d'ou.", bg_color: "#F1C40F", emoji: "🥚" },
  { name: "Peix", desc: "Peix i productes a base de peix.", bg_color: "#1ABC9C", emoji: "🐟" },
  { name: "Crustacis", desc: "Crustacis i productes a base de crustacis.", bg_color: "#E74C3C", emoji: "🦐" },
  { name: "Mol·luscs", desc: "Mol·luscs i productes a base de mol·luscs.", bg_color: "#2C3E50", emoji: "🦑" },
  { name: "Cacahuets", desc: "Cacauets i productes a base de cacauets.", bg_color: "#8E44AD", emoji: "🥜" },
  { name: "Fruits de closca", desc: "Ametlles, avellanes, nous, anacards, festucs i derivats.", bg_color: "#D35400", emoji: "🌰" },
  { name: "Sèsam", desc: "Grans de sèsam i productes a base de sèsam.", bg_color: "#95A5A6", emoji: "🌱" },
  { name: "Celerí", desc: "Api i productes derivats.", bg_color: "#27AE60", emoji: "🌿" },
  { name: "Mostassa", desc: "Mostassa i productes derivats.", bg_color: "#F39C12", emoji: "🌶️" },
  { name: "Sulfits", desc: "Diòxid de sofre i sulfits (> 10 mg/kg o 10 mg/l SO2).", bg_color: "#7F8C8D", emoji: "🍷" },
  { name: "Altramús", desc: "Tramussos i productes a base de tramussos.", bg_color: "#F1C40F", emoji: "🫘" },
  { name: "Soja", desc: "Soja i productes a base de soja.", bg_color: "#2ECC71", emoji: "🌱" }
]

eu_allergens.each do |allergen|
  r = Restriction.find_or_initialize_by(name: allergen[:name])
  r.restriction_type = :intolerance_allergy
  r.description = allergen[:desc]
  r.bg_color = allergen[:bg_color]
  r.icon_svg = emoji_icon(allergen[:emoji])
  r.save!
end

# Diet Restrictions
restrictions = [
  { name: "Halal", desc: "Requisits alimentaris islàmics.", bg_color: "#16A085", emoji: "🕌", restriction_type: :diet },
  { name: "Kosher", desc: "Requisits alimentaris jueus.", bg_color: "#2980B9", emoji: "✡️", restriction_type: :diet },
  { name: "Hindú", desc: "Restriccions alimentàries hinduistes.", bg_color: "#E67E22", emoji: "🕉️", restriction_type: :diet },
  { name: "Budista", desc: "Restriccions alimentàries budistes.", bg_color: "#F39C12", emoji: "☸️", restriction_type: :diet },
  { name: "Vegà", desc: "Sense cap producte d'origen animal.", bg_color: "#27AE60", emoji: "🌿", restriction_type: :diet },
  { name: "Vegetarià", desc: "Sense carn ni peix.", bg_color: "#2ECC71", emoji: "🥗", restriction_type: :diet }
]

restrictions.each do |restriction|
  r = Restriction.find_or_initialize_by(name: restriction[:name])
  r.restriction_type = restriction[:restriction_type]
  r.description = restriction[:desc]
  r.bg_color = restriction[:bg_color]
  r.icon_svg = emoji_icon(restriction[:emoji])
  r.save!
end

ingredients_data = [
  { name: "Farina de blat", description: "Farina procedent del blat, base de pa i pasta.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Llet sencera", description: "Llet de vaca sencera pasteuritzada.", restrictions: [ "Llet" ] },
  { name: "Ou de gallina", description: "Ou fresc de gallina.", restrictions: [ "Ous" ] },
  { name: "Gamba", description: "Gamba fresca de la Mediterrània.", restrictions: [ "Crustacis" ] },
  { name: "Salmó fresc", description: "Filet de salmó fresc.", restrictions: [ "Peix" ] },
  { name: "Soja texturitzada", description: "Proteïna de soja texturitzada.", restrictions: [ "Soja" ] },
  { name: "Ametlla", description: "Ametlla crua sense pell.", restrictions: [ "Fruits de closca" ] },
  { name: "Cacahuet torrat", description: "Cacahuets torrats sense sal.", restrictions: [ "Cacahuets" ] },
  { name: "Salsa de mostassa", description: "Mostassa de Dijon.", restrictions: [ "Mostassa" ] },
  { name: "Pa de sèsam", description: "Pa elaborat amb grans de sèsam.", restrictions: [ "Gluten (Cereals)", "Sèsam" ] },
  { name: "Tomàquet", description: "Tomàquet madur de temporada.", restrictions: [] },
  { name: "Oli d'oliva", description: "Oli d'oliva verge extra.", restrictions: [] },
  { name: "Carn de vedella", description: "Carn fresca de vedella.", restrictions: [] },
  { name: "Truita", description: "Truita fresca de riu.", restrictions: [ "Peix" ] },
  { name: "Pollastre", description: "Pit de pollastre fresc.", restrictions: [] },
  { name: "Merluça", description: "Merluça fresca del Mediterrani.", restrictions: [ "Peix" ] },
  { name: "Verduretes variades", description: "Bròquil, sípia, sègol i altres.", restrictions: [] },
  { name: "Herbes aromàtiques", description: "Farigola, romaní i altres herbes.", restrictions: [] },
  { name: "Xocolata negra", description: "Xocolata negra 70% cacao.", restrictions: [] },
  { name: "Vainilla", description: "Extracte de vainilla.", restrictions: [] },
  { name: "Caramel", description: "Caramel casolà.", restrictions: [ "Llet" ] },
  { name: "Mascarpone", description: "Formatge mascarpone italià.", restrictions: [ "Llet" ] },
  { name: "Café", description: "Café natural sense cafeina.", restrictions: [] },
  { name: "Galetes digestives", description: "Galetes digestives sense afegits.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Berena de bosc", description: "Framboesa, aranya, gerds.", restrictions: [] },
  { name: "Porc", description: "Carn fresca de porc.", restrictions: [ "Halal", "Kosher" ] },
  { name: "Pernil", description: "Pernil curat de porc (serrano o ibèric).", restrictions: [ "Halal", "Kosher" ] },
  { name: "Llonganissa", description: "Embotit de porc curat.", restrictions: [ "Halal", "Kosher" ] },
  { name: "Botifarra", description: "Salsitxa fresca de porc.", restrictions: [ "Halal", "Kosher" ] },
  { name: "Xoriç", description: "Embotit de porc amb pebre vermell.", restrictions: [ "Halal", "Kosher" ] },
  { name: "Bacon", description: "Cansalada fumada de porc.", restrictions: [ "Halal", "Kosher" ] },
  { name: "Cansalada", description: "Cansalada de porc salada.", restrictions: [ "Halal", "Kosher" ] }
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

gluten_restrict = Restriction.find_by!(name: "Gluten (Cereals)")
lactose_restrict = Restriction.find_by!(name: "Llet")
fish_restrict = Restriction.find_by!(name: "Peix")
crustacean_restrict = Restriction.find_by!(name: "Crustacis")
vegan_restrict = Restriction.find_by!(name: "Vegà")
vegetarian_restrict = Restriction.find_by!(name: "Vegetarià")

entrant_pa = Dish.find_or_create_by!(name: "Pa amb tomàquet") do |p|
  p.description = "Pa torrat amb tomàquet i oli d'oliva verge"
  p.dish_type = :entrant
end
entrant_pa.ingredients = [
  Ingredient.find_by!(name: "Pa de sèsam"),
  Ingredient.find_by!(name: "Tomàquet"),
  Ingredient.find_by!(name: "Oli d'oliva")
]

entrant_olivas = Dish.find_or_create_by!(name: "Olivas variades") do |p|
  p.description = "Olives de diverses varietats amb herbes aromàtiques"
  p.dish_type = :entrant
end
entrant_olivas.ingredients = [
  Ingredient.find_by!(name: "Oli d'oliva"),
  Ingredient.find_by!(name: "Herbes aromàtiques")
]

entrant_gamba = Dish.find_or_create_by!(name: "Gamba amb mostassa") do |p|
  p.description = "Gambeta amb salsa de mostassa i herbes"
  p.dish_type = :entrant
end
entrant_gamba.ingredients = [
  Ingredient.find_by!(name: "Gamba"),
  Ingredient.find_by!(name: "Salsa de mostassa"),
  Ingredient.find_by!(name: "Oli d'oliva")
]

entrant_tomata = Dish.find_or_create_by!(name: "Tomata amb formatge") do |p|
  p.description = "Tomata fresca amb mozzarella"
  p.dish_type = :entrant
end
entrant_tomata.ingredients = [
  Ingredient.find_by!(name: "Tomàquet"),
  Ingredient.find_by!(name: "Llet sencera")
]

primer_paella = Dish.find_or_create_by!(name: "Paella de marisco") do |p|
  p.description = "Paella amb gamba, musclo i altres mariscos"
  p.dish_type = :primer
end
primer_paella.ingredients = [
  Ingredient.find_by!(name: "Farina de blat"),
  Ingredient.find_by!(name: "Gamba"),
  Ingredient.find_by!(name: "Oli d'oliva"),
  Ingredient.find_by!(name: "Verduretes variades")
]

primer_macarrons = Dish.find_or_create_by!(name: "Macarrons a la carbonara") do |p|
  p.description = "Pasta amb salsa carbonara clàssica"
  p.dish_type = :primer
end
primer_macarrons.ingredients = [
  Ingredient.find_by!(name: "Farina de blat"),
  Ingredient.find_by!(name: "Ou de gallina"),
  Ingredient.find_by!(name: "Llet sencera"),
  Ingredient.find_by!(name: "Bacon"),
  Ingredient.find_by!(name: "Oli d'oliva")
]

primer_arros = Dish.find_or_create_by!(name: "Arròs a banda") do |p|
  p.description = "Arròs cuinat amb brou de peix i verdures"
  p.dish_type = :primer
end
primer_arros.ingredients = [
  Ingredient.find_by!(name: "Oli d'oliva"),
  Ingredient.find_by!(name: "Verduretes variades")
]

primer_macarrons_vegana = Dish.find_or_create_by!(name: "Macarrons vegans") do |p|
  p.description = "Pasta sense gluten amb salsa de tomàquet i soja"
  p.dish_type = :primer
end
primer_macarrons_vegana.ingredients = [
  Ingredient.find_by!(name: "Oli d'oliva"),
  Ingredient.find_by!(name: "Tomàquet"),
  Ingredient.find_by!(name: "Soja texturitzada"),
  Ingredient.find_by!(name: "Herbes aromàtiques")
]

segon_salmó = Dish.find_or_create_by!(name: "Salmó a la sal") do |p|
  p.description = "Filet de salmó cuinat a la sal amb herbes"
  p.dish_type = :segon
end
segon_salmó.ingredients = [
  Ingredient.find_by!(name: "Salmó fresc"),
  Ingredient.find_by!(name: "Herbes aromàtiques"),
  Ingredient.find_by!(name: "Oli d'oliva")
]

segon_pollastre = Dish.find_or_create_by!(name: "Pollastre al forn") do |p|
  p.description = "Pollastre rostit amb herbes aromàtiques i patates"
  p.dish_type = :segon
end
segon_pollastre.ingredients = [
  Ingredient.find_by!(name: "Pollastre"),
  Ingredient.find_by!(name: "Herbes aromàtiques"),
  Ingredient.find_by!(name: "Oli d'oliva"),
  Ingredient.find_by!(name: "Verduretes variades")
]

segon_truita = Dish.find_or_create_by!(name: "Truita a la meunière") do |p|
  p.description = "Truita fresca amb salsa de mantega i llimona"
  p.dish_type = :segon
end
segon_truita.ingredients = [
  Ingredient.find_by!(name: "Truita"),
  Ingredient.find_by!(name: "Llet sencera"),
  Ingredient.find_by!(name: "Oli d'oliva")
]

segon_merluça = Dish.find_or_create_by!(name: "Merluça al vapor") do |p|
  p.description = "Merluça fresca al vapor amb verduretes"
  p.dish_type = :segon
end
segon_merluça.ingredients = [
  Ingredient.find_by!(name: "Merluça"),
  Ingredient.find_by!(name: "Verduretes variades"),
  Ingredient.find_by!(name: "Oli d'oliva"),
  Ingredient.find_by!(name: "Herbes aromàtiques")
]

segon_vedella = Dish.find_or_create_by!(name: "Vedella amb salsa") do |p|
  p.description = "Carn de vedella cuinada amb verdures"
  p.dish_type = :segon
end
segon_vedella.ingredients = [
  Ingredient.find_by!(name: "Carn de vedella"),
  Ingredient.find_by!(name: "Verduretes variades"),
  Ingredient.find_by!(name: "Oli d'oliva"),
  Ingredient.find_by!(name: "Herbes aromàtiques")
]

postre_gelat = Dish.find_or_create_by!(name: "Gelat artesanal") do |p|
  p.description = "Gelat casolà amb sabors variats: vainella, xocolata, pistacho"
  p.dish_type = :postre
end
postre_gelat.ingredients = [
  Ingredient.find_by!(name: "Llet sencera"),
  Ingredient.find_by!(name: "Vainilla"),
  Ingredient.find_by!(name: "Xocolata negra")
]

postre_flan = Dish.find_or_create_by!(name: "Flà tradicional") do |p|
  p.description = "Flà clàssic amb caramel crematosquè"
  p.dish_type = :postre
end
postre_flan.ingredients = [
  Ingredient.find_by!(name: "Ou de gallina"),
  Ingredient.find_by!(name: "Llet sencera"),
  Ingredient.find_by!(name: "Caramel")
]

postre_tiramisú = Dish.find_or_create_by!(name: "Tiramisú") do |p|
  p.description = "Postre italià amb mascarpone i cacao"
  p.dish_type = :postre
end
postre_tiramisú.ingredients = [
  Ingredient.find_by!(name: "Ou de gallina"),
  Ingredient.find_by!(name: "Mascarpone"),
  Ingredient.find_by!(name: "Café"),
  Ingredient.find_by!(name: "Xocolata negra")
]

postre_brownie = Dish.find_or_create_by!(name: "Brownie de xocolata") do |p|
  p.description = "Brownie casolà amb xocolata fon al centre"
  p.dish_type = :postre
end
postre_brownie.ingredients = [
  Ingredient.find_by!(name: "Farina de blat"),
  Ingredient.find_by!(name: "Xocolata negra"),
  Ingredient.find_by!(name: "Ou de gallina"),
  Ingredient.find_by!(name: "Llet sencera")
]

postre_sorbet = Dish.find_or_create_by!(name: "Sorbet de fruites") do |p|
  p.description = "Sorbet vegà amb fruites del bosc"
  p.dish_type = :postre
end
postre_sorbet.ingredients = [
  Ingredient.find_by!(name: "Berena de bosc"),
  Ingredient.find_by!(name: "Oli d'oliva")
]

entrant_embotits = Dish.find_or_create_by!(name: "Taula d'embotits") do |p|
  p.description = "Selecció de pernil, llonganissa i xoriç artesans"
  p.dish_type = :entrant
end
entrant_embotits.ingredients = [
  Ingredient.find_by!(name: "Pernil"),
  Ingredient.find_by!(name: "Llonganissa"),
  Ingredient.find_by!(name: "Xoriç")
]

segon_porc = Dish.find_or_create_by!(name: "Llom de porc a la brasa") do |p|
  p.description = "Llom de porc a la brasa amb cansalada i herbes aromàtiques"
  p.dish_type = :segon
end
segon_porc.ingredients = [
  Ingredient.find_by!(name: "Porc"),
  Ingredient.find_by!(name: "Cansalada"),
  Ingredient.find_by!(name: "Herbes aromàtiques"),
  Ingredient.find_by!(name: "Oli d'oliva")
]

Menu.find_or_create_by!(name: "Menú setmanal") do |m|
  m.dishes = [ entrant_pa, primer_paella, segon_salmó, postre_gelat ]
end

Menu.find_or_create_by!(name: "Menú degustació") do |m|
  m.dishes = [ entrant_gamba, primer_macarrons, segon_pollastre, postre_flan ]
end

Menu.find_or_create_by!(name: "Menú sense gluten") do |m|
  m.dishes = [ entrant_olivas, primer_arros, segon_vedella, postre_sorbet ]
end

Menu.find_or_create_by!(name: "Menú vegà") do |m|
  m.dishes = [ entrant_olivas, primer_macarrons_vegana, segon_vedella, postre_sorbet ]
end

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
