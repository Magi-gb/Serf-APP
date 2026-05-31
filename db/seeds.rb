# ============================================================================
# Serf — Llavors de la base de dades
#
# Ordre de creació (de menys a més dependent):
#   1. Usuaris
#   2. Restriccions   (al·lèrgens UE + dietes)
#   3. Ingredients    (cada un amb les seves restriccions)
#   4. Elaboracions   (salses i bases; les seves restriccions deriven dels
#                      ingredients, no es guarden)
#   5. Plats          (10 per tipus: entrant, primer, segon, postre)
#   6. Menús          (combinacions coherents de plats)
#   7. Protocols
#
# Catàleg de cuina catalana i mediterrània. Tots els ingredients i elaboracions
# definits aquí són utilitzats per algun plat.
# ============================================================================

# ----------------------------------------------------------------------------
# 1. USUARIS
# ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# 2. RESTRICCIONS
# ----------------------------------------------------------------------------

# Els 14 al·lèrgens de declaració obligatòria de la UE.
eu_allergens = [
  { name: "Gluten (Cereals)", desc: "Cereals que continguin gluten i productes derivats." },
  { name: "Llet", desc: "Llet i els seus derivats (inclosa la lactosa)." },
  { name: "Ous", desc: "Ous i productes a base d'ou." },
  { name: "Peix", desc: "Peix i productes a base de peix." },
  { name: "Crustacis", desc: "Crustacis i productes a base de crustacis." },
  { name: "Mol·luscs", desc: "Mol·luscs i productes a base de mol·luscs." },
  { name: "Cacahuets", desc: "Cacauets i productes a base de cacauets." },
  { name: "Fruits de closca", desc: "Ametlles, avellanes, nous, anacards, festucs i derivats." },
  { name: "Sèsam", desc: "Grans de sèsam i productes a base de sèsam." },
  { name: "Celerí", desc: "Api i productes derivats." },
  { name: "Mostassa", desc: "Mostassa i productes derivats." },
  { name: "Sulfits", desc: "Diòxid de sofre i sulfits (> 10 mg/kg o 10 mg/l SO2)." },
  { name: "Altramús", desc: "Tramussos i productes a base de tramussos." },
  { name: "Soja", desc: "Soja i productes a base de soja." }
]

eu_allergens.each do |allergen|
  r = Restriction.find_or_initialize_by(name: allergen[:name])
  r.restriction_type = :intolerance_allergy
  r.description = allergen[:desc]
  r.save!
end

# Dietes (un ingredient es marca amb la dieta que INCOMPLEIX).
diet_restrictions = [
  { name: "Halal", desc: "Requisits alimentaris islàmics." },
  { name: "Kosher", desc: "Requisits alimentaris jueus." },
  { name: "Hindú", desc: "Restriccions alimentàries hinduistes." },
  { name: "Vegà", desc: "Sense cap producte d'origen animal." },
  { name: "Vegetarià", desc: "Sense carn ni peix." }
]

diet_restrictions.each do |restriction|
  r = Restriction.find_or_initialize_by(name: restriction[:name])
  r.restriction_type = :diet
  r.description = restriction[:desc]
  r.save!
end

# La dieta budista s'ha retirat del catàleg.
Restriction.where(name: "Budista").destroy_all

# ----------------------------------------------------------------------------
# 3. INGREDIENTS
#
# Agrupacions de dietes incompatibles, per evitar repeticions:
#   non_veg   → qualsevol carn, aviram, peix o marisc
#   pork      → derivats del porc (a més, no halal ni kosher)
#   beef      → derivats de la vedella (a més, no hindú)
#   shellfish → crustacis i mol·luscs (a més, no kosher)
#   byproduct → ous, làctics i mel (no vegà, però sí vegetarià)
#   wine      → begudes alcohòliques (porten sulfits i no són halal)
# ----------------------------------------------------------------------------
non_veg   = %w[Vegetarià Vegà]
pork      = non_veg + %w[Halal Kosher]
beef      = non_veg + %w[Hindú]
shellfish = non_veg + %w[Kosher]
byproduct = %w[Vegà]
wine      = %w[Sulfits Halal]

ingredients_data = [
  # --- Cereals i fleca (gluten) ---
  { name: "Farina de blat", description: "Farina de blat, base de masses, arrebossats i salses.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Pa de pagès", description: "Pa de pagès de crosta gruixuda.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Pa ratllat", description: "Pa sec ratllat per arrebossar i lligar farciments.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Fideus", description: "Fideus de sèmola de blat.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Macarrons", description: "Pasta seca de blat en forma de tub.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Galets", description: "Pasta gran de blat per a sopes i escudelles.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Plaques de canelons", description: "Làmines de pasta de blat per a canelons.", restrictions: [ "Gluten (Cereals)" ] },
  { name: "Melindros", description: "Bescuits ensucrats i tous, fets amb ou.", restrictions: [ "Gluten (Cereals)", "Ous" ] + byproduct },
  { name: "Arròs", description: "Arròs rodó de gra mitjà.", restrictions: [] },
  { name: "Maizena", description: "Midó de blat de moro per espessir cremes.", restrictions: [] },

  # --- Làctics ---
  { name: "Llet sencera", description: "Llet de vaca sencera pasteuritzada.", restrictions: [ "Llet" ] + byproduct },
  { name: "Mantega", description: "Mantega elaborada amb nata de vaca.", restrictions: [ "Llet" ] + byproduct },
  { name: "Nata líquida", description: "Nata de vaca per cuinar.", restrictions: [ "Llet" ] + byproduct },
  { name: "Formatge ratllat", description: "Formatge curat ratllat per gratinar.", restrictions: [ "Llet" ] + byproduct },
  { name: "Mató", description: "Formatge fresc de llet, sense sal.", restrictions: [ "Llet" ] + byproduct },
  { name: "Mascarpone", description: "Formatge cremós italià a base de nata.", restrictions: [ "Llet" ] + byproduct },

  # --- Ous ---
  { name: "Ou de gallina", description: "Ou fresc de gallina.", restrictions: [ "Ous" ] + byproduct },

  # --- Peix ---
  { name: "Bacallà", description: "Bacallà salat i dessalat.", restrictions: [ "Peix" ] + non_veg },
  { name: "Anxova", description: "Filets d'anxova en oli.", restrictions: [ "Peix" ] + non_veg },
  { name: "Rap", description: "Cua de rap fresc.", restrictions: [ "Peix" ] + non_veg },
  { name: "Peix de roca", description: "Peix de roca per a brou i sopa marinera.", restrictions: [ "Peix" ] + non_veg },

  # --- Crustacis ---
  { name: "Gamba", description: "Gamba fresca de la Mediterrània.", restrictions: [ "Crustacis" ] + shellfish },

  # --- Mol·luscs ---
  { name: "Sípia", description: "Sípia fresca i neta.", restrictions: [ "Mol·luscs" ] + shellfish },
  { name: "Calamar", description: "Calamar fresc tallat a anelles.", restrictions: [ "Mol·luscs" ] + shellfish },
  { name: "Musclo", description: "Musclos frescos de roca.", restrictions: [ "Mol·luscs" ] + shellfish },
  { name: "Tinta de sípia", description: "Tinta natural de sípia.", restrictions: [ "Mol·luscs" ] + shellfish },

  # --- Carns ---
  { name: "Carn de vedella", description: "Carn magra de vedella.", restrictions: beef },
  { name: "Carn de porc", description: "Carn magra de porc.", restrictions: pork },
  { name: "Llom de porc", description: "Llom de porc tallat a talls.", restrictions: pork },
  { name: "Pollastre", description: "Pit i cuixa de pollastre.", restrictions: non_veg },
  { name: "Xai", description: "Costelles i carn de xai.", restrictions: non_veg },
  { name: "Pernil", description: "Pernil curat de porc.", restrictions: pork },
  { name: "Botifarra", description: "Botifarra fresca de porc.", restrictions: pork },
  { name: "Cansalada", description: "Cansalada de porc per sofregir.", restrictions: pork },
  { name: "Llardons", description: "Greix de porc fregit i cruixent.", restrictions: pork },

  # --- Fruits de closca ---
  # Nota: els pinyons no figuren a la llista oficial UE de fruits de closca
  # (ametlla, avellana, nou, anacard, festuc...), per això no s'hi associen.
  { name: "Ametlla", description: "Ametlla crua pelada.", restrictions: [ "Fruits de closca" ] },
  { name: "Avellana", description: "Avellana torrada.", restrictions: [ "Fruits de closca" ] },
  { name: "Nou", description: "Nou pelada.", restrictions: [ "Fruits de closca" ] },
  { name: "Pinyó", description: "Pinyons de pi mediterrani.", restrictions: [] },

  # --- Verdures, llegums i hortalisses ---
  { name: "Tomàquet", description: "Tomàquet madur de temporada.", restrictions: [] },
  { name: "Ceba", description: "Ceba de Figueres.", restrictions: [] },
  { name: "All", description: "All sec.", restrictions: [] },
  { name: "Porro", description: "Porro fresc.", restrictions: [] },
  { name: "Albergínia", description: "Albergínia morada.", restrictions: [] },
  { name: "Pebrot vermell", description: "Pebrot vermell de carn gruixuda.", restrictions: [] },
  { name: "Carxofa", description: "Carxofes fresques del Prat.", restrictions: [] },
  { name: "Escarola", description: "Escarola arrissada.", restrictions: [] },
  { name: "Patata", description: "Patata per bullir i fregir.", restrictions: [] },
  { name: "Carbassa", description: "Carbassa dolça.", restrictions: [] },
  { name: "Espinac", description: "Espinacs frescos.", restrictions: [] },
  { name: "Pastanaga", description: "Pastanaga fresca.", restrictions: [] },
  { name: "Api", description: "Api fresc.", restrictions: [ "Celerí" ] },
  { name: "Cigró", description: "Cigrons cuits.", restrictions: [] },
  { name: "Mongetes seques", description: "Mongetes blanques seques cuites.", restrictions: [] },
  { name: "Col", description: "Col verda d'hivern.", restrictions: [] },
  { name: "Bolets", description: "Bolets de temporada (rovellons, moixernons).", restrictions: [] },
  { name: "Olives negres", description: "Olives negres d'Aragó.", restrictions: [] },

  # --- Fruites ---
  { name: "Llimona", description: "Llimona fresca.", restrictions: [] },
  { name: "Poma", description: "Poma fresca.", restrictions: [] },
  { name: "Taronja", description: "Taronja de suc.", restrictions: [] },
  { name: "Plàtan", description: "Plàtan madur.", restrictions: [] },
  { name: "Maduixa", description: "Maduixes fresques.", restrictions: [] },
  { name: "Prunes", description: "Prunes seques sense pinyol.", restrictions: [] },
  { name: "Panses", description: "Panses de Corint.", restrictions: [] },
  { name: "Moniato", description: "Moniato dolç.", restrictions: [] },

  # --- Herbes, espècies i condiments ---
  { name: "Julivert", description: "Julivert fresc.", restrictions: [] },
  { name: "Romaní", description: "Romaní fresc.", restrictions: [] },
  { name: "Safrà", description: "Brins de safrà.", restrictions: [] },
  { name: "Nyora", description: "Nyora seca (pebrot dolç assecat).", restrictions: [] },
  { name: "Canyella", description: "Canyella en branca.", restrictions: [] },
  { name: "Pebre vermell", description: "Pebre vermell dolç.", restrictions: [] },
  { name: "Pebre de caiena", description: "Pebre de caiena picant.", restrictions: [] },
  { name: "Vainilla", description: "Beina de vainilla.", restrictions: [] },
  { name: "Sal", description: "Sal marina.", restrictions: [] },
  { name: "Oli d'oliva", description: "Oli d'oliva verge extra.", restrictions: [] },
  { name: "Vinagre", description: "Vinagre de vi.", restrictions: [ "Sulfits" ] },
  { name: "Sucre", description: "Sucre blanc.", restrictions: [] },

  # --- Begudes alcohòliques ---
  { name: "Vi negre", description: "Vi negre de taula.", restrictions: wine },
  { name: "Vi blanc", description: "Vi blanc sec.", restrictions: wine },
  { name: "Vi ranci", description: "Vi ranci català.", restrictions: wine },

  # --- Altres ---
  { name: "Xocolata negra", description: "Xocolata negra 70% de cacau.", restrictions: [] },
  { name: "Cacau en pols", description: "Cacau pur en pols, sense sucre.", restrictions: [] },
  { name: "Cafè", description: "Cafè torrat i mòlt.", restrictions: [] },
  { name: "Mel", description: "Mel de mil flors.", restrictions: byproduct }
]

ingredients_data.each do |data|
  ingredient = Ingredient.find_or_initialize_by(name: data[:name])
  ingredient.description = data[:description]
  ingredient.save!
  ingredient.restrictions = data[:restrictions].uniq.map { |name| Restriction.find_by!(name: name) }
end

# ----------------------------------------------------------------------------
# 4. ELABORACIONS
# ----------------------------------------------------------------------------
elaborations_data = [
  { name: "Sofregit",
    description: "Base de ceba i tomàquet confitats a foc lent amb oli.",
    ingredients: [ "Ceba", "Tomàquet", "All", "Oli d'oliva" ] },
  { name: "Picada",
    description: "Picada de fruits secs, all, julivert i pa per lligar guisats.",
    ingredients: [ "Ametlla", "Avellana", "All", "Julivert", "Pa de pagès", "Safrà" ] },
  { name: "Beixamel",
    description: "Salsa blanca clàssica de llet, farina i mantega.",
    ingredients: [ "Llet sencera", "Farina de blat", "Mantega" ] },
  { name: "Romesco",
    description: "Salsa de fruits secs, nyora, tomàquet i all.",
    ingredients: [ "Ametlla", "Avellana", "Tomàquet", "All", "Nyora", "Pa de pagès", "Oli d'oliva", "Vinagre" ] },
  { name: "Allioli",
    description: "Emulsió tradicional d'all i oli d'oliva.",
    ingredients: [ "All", "Oli d'oliva" ] },
  { name: "Salsa bolonyesa",
    description: "Salsa de carn de vedella i sofregit lligada amb vi negre.",
    ingredients: [ "Carn de vedella", "Tomàquet", "Ceba", "Pastanaga", "Vi negre", "Oli d'oliva" ] },
  { name: "Brou de peix",
    description: "Brou concentrat de peix de roca i verdures.",
    ingredients: [ "Peix de roca", "Ceba", "Pastanaga", "Api", "Tomàquet" ] },
  { name: "Salsa brava",
    description: "Salsa lleugerament picant de pebre vermell i caiena.",
    ingredients: [ "Oli d'oliva", "Farina de blat", "Pebre vermell", "All", "Pebre de caiena" ] },
  { name: "Caramel",
    description: "Caramel líquid de sucre fos.",
    ingredients: [ "Sucre" ] },
  { name: "Pilota de l'olla",
    description: "Mandonguilla gran de carn per a l'escudella.",
    ingredients: [ "Carn de vedella", "Carn de porc", "Ou de gallina", "Pa ratllat", "All", "Julivert" ] }
]

elaborations_data.each do |data|
  elaboration = Elaboration.find_or_initialize_by(name: data[:name])
  elaboration.description = data[:description]
  elaboration.save!
  elaboration.ingredients = data[:ingredients].map { |name| Ingredient.find_by!(name: name) }
end

# ----------------------------------------------------------------------------
# 5. PLATS
#
# build_dish marca per defecte els ingredients com a essencials (bloquejants) i
# rebaixa a substituïbles els de la llista `replaceable`.
# ----------------------------------------------------------------------------
def build_dish(name:, type:, description:, essential:, replaceable: [], elaborations: [])
  dish = Dish.find_or_initialize_by(name: name)
  dish.description = description
  dish.dish_type = type
  dish.ingredients = (essential + replaceable).map { |n| Ingredient.find_by!(name: n) }
  dish.elaborations = elaborations.map { |n| Elaboration.find_by!(name: n) }
  dish.save!
  replaceable.each do |n|
    dish.dish_ingredients.find_by!(ingredient: Ingredient.find_by!(name: n)).update!(essential: false)
  end
end

# --- Entrants ---
build_dish(
  name: "Pa amb tomàquet", type: :entrant,
  description: "Llesques de pa de pagès torrades, fregades amb tomàquet i all i amanides amb oli.",
  essential: [ "Pa de pagès", "Tomàquet" ], replaceable: [ "All", "Oli d'oliva", "Sal" ]
)
build_dish(
  name: "Esqueixada de bacallà", type: :entrant,
  description: "Bacallà cru esqueixat amb tomàquet, ceba i olives negres.",
  essential: [ "Bacallà", "Tomàquet" ], replaceable: [ "Ceba", "Olives negres", "Oli d'oliva", "Vinagre" ]
)
build_dish(
  name: "Escalivada amb anxoves", type: :entrant,
  description: "Verdures escalivades a la brasa amb filets d'anxova i oli.",
  essential: [ "Albergínia", "Pebrot vermell" ], replaceable: [ "Ceba", "Anxova", "Oli d'oliva" ]
)
build_dish(
  name: "Croquetes de pernil", type: :entrant,
  description: "Croquetes cremoses de pernil arrebossades i fregides.",
  essential: [ "Pernil", "Pa ratllat" ], replaceable: [ "Ou de gallina", "Oli d'oliva" ],
  elaborations: [ "Beixamel" ]
)
build_dish(
  name: "Calamars a la romana", type: :entrant,
  description: "Anelles de calamar arrebossades amb farina i ou i fregides.",
  essential: [ "Calamar", "Farina de blat" ], replaceable: [ "Ou de gallina", "Oli d'oliva", "Llimona" ]
)
build_dish(
  name: "Musclos a la marinera", type: :entrant,
  description: "Musclos al vapor amb sofregit, vi blanc i julivert.",
  essential: [ "Musclo" ], replaceable: [ "Vi blanc", "Julivert" ],
  elaborations: [ "Sofregit" ]
)
build_dish(
  name: "Carxofes a la brasa amb romesco", type: :entrant,
  description: "Carxofes a la brasa acompanyades de salsa romesco.",
  essential: [ "Carxofa" ], replaceable: [ "Oli d'oliva", "Sal" ],
  elaborations: [ "Romesco" ]
)
build_dish(
  name: "Patates braves", type: :entrant,
  description: "Daus de patata fregits amb salsa brava i allioli.",
  essential: [ "Patata" ], replaceable: [ "Oli d'oliva" ],
  elaborations: [ "Salsa brava", "Allioli" ]
)
build_dish(
  name: "Coca de recapte", type: :entrant,
  description: "Coca de pa de pagès amb escalivada i anxoves al damunt.",
  essential: [ "Farina de blat" ], replaceable: [ "Albergínia", "Pebrot vermell", "Anxova", "Oli d'oliva" ]
)
build_dish(
  name: "Amanida d'escarola amb fruits secs", type: :entrant,
  description: "Escarola amb nous, avellanes, olives i vinagreta.",
  essential: [ "Escarola" ], replaceable: [ "Nou", "Avellana", "Olives negres", "Oli d'oliva", "Vinagre" ]
)

# --- Primers ---
build_dish(
  name: "Escudella i carn d'olla", type: :primer,
  description: "Sopa de galets amb brou de carn i la pilota de l'olla.",
  essential: [ "Galets" ], replaceable: [ "Cigró", "Patata", "Col", "Pastanaga" ],
  elaborations: [ "Pilota de l'olla" ]
)
build_dish(
  name: "Arròs negre", type: :primer,
  description: "Arròs cuinat amb sípia i la seva tinta, lligat amb sofregit i brou de peix.",
  essential: [ "Arròs", "Sípia", "Tinta de sípia" ], replaceable: [ "All", "Oli d'oliva" ],
  elaborations: [ "Sofregit", "Brou de peix" ]
)
build_dish(
  name: "Fideuà", type: :primer,
  description: "Fideus cuinats amb marisc, sofregit i brou de peix, servits amb allioli.",
  essential: [ "Fideus" ], replaceable: [ "Sípia", "Gamba", "Musclo", "Oli d'oliva" ],
  elaborations: [ "Sofregit", "Brou de peix", "Allioli" ]
)
build_dish(
  name: "Canelons de rostit", type: :primer,
  description: "Canelons farcits de carn rostida i gratinats amb beixamel i formatge.",
  essential: [ "Plaques de canelons", "Carn de porc" ], replaceable: [ "Carn de vedella", "Pollastre", "Formatge ratllat" ],
  elaborations: [ "Beixamel" ]
)
build_dish(
  name: "Macarrons gratinats", type: :primer,
  description: "Macarrons amb salsa bolonyesa gratinats amb formatge.",
  essential: [ "Macarrons" ], replaceable: [ "Formatge ratllat" ],
  elaborations: [ "Salsa bolonyesa" ]
)
build_dish(
  name: "Crema de carbassa", type: :primer,
  description: "Crema vellutada de carbassa amb un toc de nata.",
  essential: [ "Carbassa" ], replaceable: [ "Ceba", "Patata", "Porro", "Nata líquida", "Oli d'oliva" ]
)
build_dish(
  name: "Espinacs a la catalana", type: :primer,
  description: "Espinacs saltats amb panses i pinyons.",
  essential: [ "Espinac" ], replaceable: [ "Panses", "Pinyó", "All", "Oli d'oliva" ]
)
build_dish(
  name: "Sopa de peix", type: :primer,
  description: "Sopa marinera de peix de roca i gamba lligada amb picada.",
  essential: [ "Gamba" ], replaceable: [ "Tomàquet", "Pa de pagès" ],
  elaborations: [ "Brou de peix", "Sofregit", "Picada" ]
)
build_dish(
  name: "Risotto de bolets", type: :primer,
  description: "Arròs cremós amb bolets, vi blanc i formatge.",
  essential: [ "Arròs", "Bolets" ], replaceable: [ "Ceba", "Vi blanc", "Mantega", "Formatge ratllat" ]
)
build_dish(
  name: "Trinxat de la Cerdanya", type: :primer,
  description: "Puré de col i patata saltat amb all i cansalada.",
  essential: [ "Col", "Patata" ], replaceable: [ "Cansalada", "All", "Oli d'oliva" ]
)

# --- Segons ---
build_dish(
  name: "Fricandó amb moixernons", type: :segon,
  description: "Estofat de vedella amb moixernons, lligat amb picada i vi negre.",
  essential: [ "Carn de vedella" ], replaceable: [ "Bolets", "Farina de blat", "Vi negre", "Oli d'oliva" ],
  elaborations: [ "Sofregit", "Picada" ]
)
build_dish(
  name: "Pollastre a la catalana", type: :segon,
  description: "Pollastre guisat amb prunes, pinyons i vi ranci.",
  essential: [ "Pollastre" ], replaceable: [ "Prunes", "Pinyó", "Vi ranci" ],
  elaborations: [ "Sofregit", "Picada" ]
)
build_dish(
  name: "Bacallà a la llauna", type: :segon,
  description: "Bacallà enfarinat i cuit al forn amb all, pebre vermell i vi blanc.",
  essential: [ "Bacallà" ], replaceable: [ "Farina de blat", "All", "Pebre vermell", "Vi blanc", "Oli d'oliva" ]
)
build_dish(
  name: "Suquet de rap", type: :segon,
  description: "Guisat mariner de rap i gamba amb patata, lligat amb picada.",
  essential: [ "Rap" ], replaceable: [ "Gamba", "Patata", "Oli d'oliva" ],
  elaborations: [ "Sofregit", "Picada" ]
)
build_dish(
  name: "Botifarra amb mongetes", type: :segon,
  description: "Botifarra a la brasa amb mongetes seques saltades.",
  essential: [ "Botifarra", "Mongetes seques" ], replaceable: [ "All", "Oli d'oliva" ]
)
build_dish(
  name: "Costelles de xai al forn", type: :segon,
  description: "Costelles de xai rostides amb patata, all i romaní.",
  essential: [ "Xai" ], replaceable: [ "Patata", "All", "Romaní", "Vi negre", "Oli d'oliva" ]
)
build_dish(
  name: "Truita de patates", type: :segon,
  description: "Truita de patata i ceba feta a la paella.",
  essential: [ "Ou de gallina", "Patata" ], replaceable: [ "Ceba", "Oli d'oliva" ]
)
build_dish(
  name: "Mandonguilles amb sípia", type: :segon,
  description: "Mar i muntanya de mandonguilles i sípia amb sofregit i picada.",
  essential: [ "Carn de vedella", "Sípia" ], replaceable: [ "Carn de porc", "Ou de gallina", "Pa ratllat", "Oli d'oliva" ],
  elaborations: [ "Sofregit", "Picada" ]
)
build_dish(
  name: "Llom de porc amb prunes", type: :segon,
  description: "Llom de porc rostit amb prunes i vi ranci.",
  essential: [ "Llom de porc" ], replaceable: [ "Prunes", "Vi ranci", "Ceba", "Oli d'oliva" ]
)
build_dish(
  name: "Verdures a la brasa amb romesco", type: :segon,
  description: "Selecció de verdures de temporada a la brasa amb salsa romesco.",
  essential: [ "Albergínia", "Pebrot vermell" ], replaceable: [ "Carxofa", "Patata", "Oli d'oliva" ],
  elaborations: [ "Romesco" ]
)

# --- Postres ---
build_dish(
  name: "Crema catalana", type: :postre,
  description: "Crema d'ou i llet amb canyella i llimona, amb sucre cremat al damunt.",
  essential: [ "Llet sencera", "Ou de gallina" ], replaceable: [ "Sucre", "Canyella", "Llimona", "Maizena" ]
)
build_dish(
  name: "Mel i mató", type: :postre,
  description: "Formatge fresc mató amb mel i nous.",
  essential: [ "Mató" ], replaceable: [ "Mel", "Nou" ]
)
build_dish(
  name: "Panellets", type: :postre,
  description: "Dolços d'ametlla i moniato recoberts de pinyons.",
  essential: [ "Ametlla" ], replaceable: [ "Sucre", "Ou de gallina", "Moniato", "Pinyó" ]
)
build_dish(
  name: "Tiramisú", type: :postre,
  description: "Postre de melindros amb mascarpone, cafè i cacau.",
  essential: [ "Melindros", "Mascarpone" ], replaceable: [ "Ou de gallina", "Cafè", "Cacau en pols" ]
)
build_dish(
  name: "Brownie de xocolata amb nous", type: :postre,
  description: "Pastís dens de xocolata negra amb nous.",
  essential: [ "Xocolata negra", "Mantega", "Ou de gallina", "Farina de blat" ], replaceable: [ "Sucre", "Nou" ]
)
build_dish(
  name: "Gelat de vainilla", type: :postre,
  description: "Gelat cremós de llet, nata i vainilla.",
  essential: [ "Llet sencera", "Nata líquida" ], replaceable: [ "Ou de gallina", "Vainilla", "Sucre" ]
)
build_dish(
  name: "Sorbet de llimona", type: :postre,
  description: "Sorbet refrescant de llimona.",
  essential: [ "Llimona" ], replaceable: [ "Sucre" ]
)
build_dish(
  name: "Macedònia de fruita", type: :postre,
  description: "Fruita fresca de temporada tallada amb suc de taronja.",
  essential: [ "Poma", "Taronja" ], replaceable: [ "Plàtan", "Maduixa" ]
)
build_dish(
  name: "Coca de llardons", type: :postre,
  description: "Coca de full amb llardons, sucre i pinyons.",
  essential: [ "Farina de blat", "Llardons" ], replaceable: [ "Ou de gallina", "Sucre", "Pinyó" ]
)
build_dish(
  name: "Flam d'ou amb caramel", type: :postre,
  description: "Flam tradicional d'ou i llet amb caramel.",
  essential: [ "Ou de gallina", "Llet sencera" ],
  elaborations: [ "Caramel" ]
)

# ----------------------------------------------------------------------------
# 6. MENÚS
# ----------------------------------------------------------------------------
menus_data = {
  "Menú del dia" => [ "Pa amb tomàquet", "Escudella i carn d'olla", "Pollastre a la catalana", "Crema catalana" ],
  "Menú de mar" => [ "Esqueixada de bacallà", "Arròs negre", "Suquet de rap", "Gelat de vainilla" ],
  "Menú de festa" => [ "Croquetes de pernil", "Canelons de rostit", "Costelles de xai al forn", "Brownie de xocolata amb nous" ],
  "Menú vegetarià" => [ "Carxofes a la brasa amb romesco", "Crema de carbassa", "Truita de patates", "Mel i mató" ],
  "Menú vegà" => [ "Patates braves", "Espinacs a la catalana", "Verdures a la brasa amb romesco", "Sorbet de llimona" ],
  "Menú sense gluten" => [ "Esqueixada de bacallà", "Crema de carbassa", "Botifarra amb mongetes", "Crema catalana" ]
}

menus_data.each do |name, dish_names|
  menu = Menu.find_or_initialize_by(name: name)
  menu.dishes = dish_names.map { |dish_name| Dish.find_by!(name: dish_name) }
  menu.save!
end

# ----------------------------------------------------------------------------
# 7. PROTOCOLS
# ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# Recàlcul final dels comptadors en memòria cau de les restriccions.
# ----------------------------------------------------------------------------
Restriction.recalculate_all_cached_counts!
