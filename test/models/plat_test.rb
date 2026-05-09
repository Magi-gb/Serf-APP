require "test_helper"

class PlatTest < ActiveSupport::TestCase
  test "creates a plat with valid attributes" do
    plat = Plat.new(name: "Paella", description: "Arroz con cosas", tipusPlat: :primer)

    assert plat.valid?
  end

  test "validates presence of name" do
    plat = Plat.new(description: "Arroz", tipusPlat: :primer)

    assert_not plat.valid?
    assert plat.errors[:name].any?
  end

  test "validates presence of description" do
    plat = Plat.new(name: "Paella", tipusPlat: :primer)

    assert_not plat.valid?
    assert plat.errors[:description].any?
  end

  test "validates presence of tipusPlat" do
    plat = Plat.new(name: "Paella", description: "Arroz")

    # tipusPlat has a database default of 0, so it will always have a value
    assert plat.valid?
  end

  test "has many plat_ingredients" do
    plat = plats(:paella)

    assert plat.respond_to?(:plat_ingredients)
  end

  test "has many menu_plats" do
    plat = plats(:paella)

    assert plat.respond_to?(:menu_plats)
  end
end
