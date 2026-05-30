# row_data_gateway_demo.rb
# PoC: Row Data Gateway Pattern Demo
# 
# Este archivo es una demostración independiente del patrón Row Data Gateway.
# Representa la entidad 'Plat' (Dish) del proyecto de forma aislada.

class PlatRowGateway
  attr_accessor :id, :name, :description, :tipus_plat

  # Simulación de la tabla 'plats' en memoria
  # Tipus de plat (enum): entrant: 0, primer: 1, segon: 2, postre: 3
  @@data = [
    { id: 1, name: "Amanida Catalana", description: "Amanida amb embotits de la terra", tipus_plat: 0 },
    { id: 2, name: "Escudella i Carn d'Olla", description: "Sopa tradicional catalana", tipus_plat: 1 }
  ]
  @@next_id = 3

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @tipus_plat = attributes[:tipus_plat] || 0
  end

  # Mapeo de nombres de tipos para visualización
  def self.tipus_nom(id_tipus)
    case id_tipus
    when 0 then "Entrant"
    when 1 then "Primer"
    when 2 then "Segon"
    when 3 then "Postre"
    else "Desconegut"
    end
  end

  def tipus_display
    self.class.tipus_nom(@tipus_plat)
  end

  # --- Métodos de Clase (Finders) ---

  def self.all
    puts "[DB] SELECT * FROM plats"
    @@data.map { |attrs| new(attrs) }
  end

  def self.find(id)
    puts "[DB] SELECT * FROM plats WHERE id = #{id} LIMIT 1"
    attrs = @@data.find { |d| d[:id] == id }
    new(attrs) if attrs
  end

  # --- Métodos de Instancia (Gateway Operations) ---

  def save
    if @id
      update
    else
      insert
    end
  end

  def delete
    if @id
      puts "[DB] DELETE FROM plats WHERE id = #{@id}"
      @@data.delete_if { |d| d[:id] == @id }
      @id = nil
      puts "Log: Eliminació del plat correcte."
    else
      puts "Error: No es pot eliminar un plat que no existeix a la base de dades."
    end
  end

  private

  def insert
    @id = @@next_id
    @@next_id += 1
    puts "[DB] INSERT INTO plats (id, name, description, tipus_plat) VALUES (#{@id}, '#{@name}', '#{@description}', #{@tipus_plat})"
    @@data << { id: @id, name: @name, description: @description, tipus_plat: @tipus_plat }
    puts "Log: Creació del nou plat '#{@name}' realitzada amb èxit."
  end

  def update
    puts "[DB] UPDATE plats SET name = '#{@name}', description = '#{@description}', tipus_plat = #{@tipus_plat} WHERE id = #{@id}"
    index = @@data.find_index { |d| d[:id] == @id }
    if index
      @@data[index] = { id: @id, name: @name, description: @description, tipus_plat: @tipus_plat }
      puts "Log: Modificació del plat '#{@name}' (ID: #{@id}) desada."
    end
  end
end

# --- Demostració Funcional ---

puts "=========================================================="
puts "  DEMOSTRACIÓ PATRÓ ROW DATA GATEWAY - ENTITAT PLAT"
puts "=========================================================="

# 1. Llistar tots els plats
puts "\n1. Llistant tots els plats de la carta:"
plats = PlatRowGateway.all
plats.each { |p| puts "   > [ID: #{p.id}] #{p.name} (#{p.tipus_display}): #{p.description}" }

# 2. Cercar un plat específic
puts "\n2. Cercant plat amb ID 2:"
p2 = PlatRowGateway.find(2)
if p2
  puts "   > Trobat: #{p2.name} - #{p2.description}"
end

# 3. Creació d'un nou plat
puts "\n3. Creació d'un nou plat (Crema Catalana):"
nou_plat = PlatRowGateway.new(
  name: "Crema Catalana", 
  description: "Postre tradicional amb sucre cremat", 
  tipus_plat: 3
)
nou_plat.save
puts "   > Nou plat registrat amb ID: #{nou_plat.id}"

# 4. Modificació d'un plat existent
puts "\n4. Modificació del plat amb ID 1:"
p1 = PlatRowGateway.find(1)
if p1
  p1.description = "Amanida variada amb productes de temporada"
  p1.tipus_plat = 0
  p1.save
end

# 5. Eliminació d'un plat
puts "\n5. Eliminació del plat amb ID 2 (Escudella):"
p2_a_eliminar = PlatRowGateway.find(2)
p2_a_eliminar.delete if p2_a_eliminar

# 6. Llistat final per verificar la consistència
puts "\n6. Llistat final de la carta actualitzada:"
PlatRowGateway.all.each { |p| puts "   > [ID: #{p.id}] #{p.name} (#{p.tipus_display}): #{p.description}" }

puts "\n=========================================================="
puts "  FI DE LA DEMOSTRACIÓ"
puts "=========================================================="
