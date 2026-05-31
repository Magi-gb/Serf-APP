# row_data_gateway_demo.rb
# PoC: Row Data Gateway Pattern
#
# Demostració independent del patró Row Data Gateway per a l'entitat Dish.
# Accedeix directament a db/development.sqlite3 sense usar ActiveRecord.
#
# Execució: ruby row_data_gateway_demo.rb
#
# AVÍS: les operacions d'escriptura modifiquen la BD de desenvolupament.
# La demo neta (pas 7) elimina les files que ella mateixa insereix.

require "sqlite3"

DB = SQLite3::Database.new(File.expand_path("db/development.sqlite3", __dir__)).tap do |conn|
  conn.results_as_hash = true
end

# ---------------------------------------------------------------------------
# Row Data Gateway — un objecte per fila de la taula `dishes`
# ---------------------------------------------------------------------------
class DishGateway
  DISH_TYPES = { 0 => "Entrant", 1 => "Primer", 2 => "Segon", 3 => "Postre" }.freeze

  attr_accessor :name, :description, :dish_type
  attr_reader   :id

  def initialize(row)
    @id          = row["id"]
    @name        = row["name"]
    @description = row["description"]
    @dish_type   = row["dish_type"] || 0
  end

  def dish_type_display
    DISH_TYPES[@dish_type] || "Desconegut"
  end

  # -------------------------------------------------------------------------
  # Finders (mètodes de classe — SELECT)
  # -------------------------------------------------------------------------

  def self.all
    run("SELECT id, name, description, dish_type FROM dishes ORDER BY id")
      .map { |row| new(row) }
  end

  def self.find(id)
    row = run(
      "SELECT id, name, description, dish_type FROM dishes WHERE id = ? LIMIT 1",
      id
    ).first
    new(row) if row
  end

  # Cerca per nom (LIKE, insensible a majúscules en SQLite per caràcters ASCII)
  def self.find_by_name(pattern)
    run(
      "SELECT id, name, description, dish_type FROM dishes WHERE name LIKE ? ORDER BY id",
      "%#{pattern}%"
    ).map { |row| new(row) }
  end

  # Cerca per tipus (0=entrant, 1=primer, 2=segon, 3=postre)
  def self.find_by_type(dish_type)
    run(
      "SELECT id, name, description, dish_type FROM dishes WHERE dish_type = ? ORDER BY id",
      dish_type
    ).map { |row| new(row) }
  end

  # -------------------------------------------------------------------------
  # Operacions de gateway (mètodes d'instància — INSERT / UPDATE / DELETE)
  # -------------------------------------------------------------------------

  # Insereix una nova fila i emplena @id amb el rowid generat
  def insert
    run(
      "INSERT INTO dishes (name, description, dish_type, created_at, updated_at)" \
      " VALUES (?, ?, ?, datetime('now'), datetime('now'))",
      @name, @description, @dish_type
    )
    @id = DB.last_insert_row_id
    puts "Log: Plat '#{@name}' inserit amb ID #{@id}."
    self
  end

  # Actualitza la fila existent corresponent a @id
  def update
    raise "No es pot actualitzar un plat sense ID." unless @id
    run(
      "UPDATE dishes SET name = ?, description = ?, dish_type = ?, updated_at = datetime('now')" \
      " WHERE id = ?",
      @name, @description, @dish_type, @id
    )
    puts "Log: Plat ID #{@id} ('#{@name}') actualitzat."
    self
  end

  # Elimina la fila i posa @id a nil
  def delete
    raise "No es pot eliminar un plat sense ID." unless @id
    run("DELETE FROM dishes WHERE id = ?", @id)
    puts "Log: Plat ID #{@id} ('#{@name}') eliminat."
    @id = nil
    self
  end

  # Getters individuals (alternativa als attr_accessor per llegibilitat)
  def to_s
    "[ID: #{@id || '(nou)'}] #{@name} (#{dish_type_display}): #{@description}"
  end

  private

  def run(sql, *args) = self.class.run(sql, *args)

  def self.run(sql, *args)
    display = args.empty? ? sql : "#{sql}  -- #{args.inspect}"
    puts "[SQL] #{display}"
    DB.execute(sql, *args)
  end
end

# ---------------------------------------------------------------------------
# Demostració funcional
# ---------------------------------------------------------------------------

puts "=" * 62
puts "  DEMOSTRACIÓ PATRÓ ROW DATA GATEWAY — ENTITAT DISH"
puts "=" * 62

# 1. Llistar tots els plats
puts "\n1. Tots els plats existents a la BD:"
DishGateway.all.each { |p| puts "   > #{p}" }

# 2. Cercar per ID
puts "\n2. Cercar plat amb ID 1:"
plat = DishGateway.find(1)
puts plat ? "   > Trobat: #{plat}" : "   > No trobat."

# 3. Cercar per nom (LIKE)
puts "\n3. Cercar plats que continguin 'saltat' al nom:"
DishGateway.find_by_name("saltat").each { |p| puts "   > #{p}" }

# 4. Cercar per tipus (entrants = 0)
puts "\n4. Cercar tots els entrants (dish_type = 0):"
DishGateway.find_by_type(0).each { |p| puts "   > #{p}" }

# 5. Inserir un nou plat
puts "\n5. Inserir un plat de prova (Crema Catalana):"
nou = DishGateway.new("id" => nil, "name" => "Crema Catalana [DEMO]",
                       "description" => "Postre tradicional amb sucre cremat", "dish_type" => 3)
nou.insert
puts "   > Nou plat: #{nou}"

# 6. Actualitzar el plat inserit
puts "\n6. Actualitzar la descripció del plat inserit:"
nou.description = "Postre tradicional català amb crema i sucre caramel·litzat"
nou.update
puts "   > Plat actualitzat: #{nou}"

# 7. Verificar l'actualització llegint de nou de la BD
puts "\n7. Rellegir el plat des de la BD per verificar l'actualització:"
rellegit = DishGateway.find(nou.id)
puts rellegit ? "   > #{rellegit}" : "   > No trobat."

# 8. Eliminar el plat de prova (neteja)
puts "\n8. Eliminar el plat de prova (neteja de la BD):"
rellegit&.delete

# 9. Llistat final per verificar consistència
puts "\n9. Llistat final (ha de ser igual al inicial):"
DishGateway.all.each { |p| puts "   > #{p}" }

puts "\n" + ("=" * 62)
puts "  FI DE LA DEMOSTRACIÓ"
puts "=" * 62
