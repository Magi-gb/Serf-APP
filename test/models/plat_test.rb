require "test_helper"

class PlatTest < ActiveSupport::TestCase
  test "is valid with name, description and tipusPlat" do
    plat = Plat.new(name: "Test Plat", description: "Test description", tipusPlat: :entrant)
    assert plat.valid?
  end

  test "validates presence of name" do
    plat = Plat.new(description: "Test", tipusPlat: :entrant)
    assert_not plat.valid?
    assert plat.errors[:name].any?
  end

  test "validates presence of description" do
    plat = Plat.new(name: "Test", tipusPlat: :entrant)
    assert_not plat.valid?
    assert plat.errors[:description].any?
  end

  test "rejects invalid tipusPlat values" do
    assert_raises(ArgumentError) do
      Plat.new(name: "Test", description: "Test", tipusPlat: :invalid_type)
    end
  end

  test "accepts all enum values for tipusPlat" do
    %i[entrant primer segon postre].each do |type|
      plat = Plat.new(name: "Plat #{type}", description: "d", tipusPlat: type)
      assert_equal type.to_s, plat.tipusPlat
    end
  end

  test "strips whitespace from name before validation" do
    plat = Plat.new(name: "  Paella  ", description: "Test", tipusPlat: :primer)
    plat.valid?
    assert_equal "Paella", plat.name
  end

  test "has many menus through menu_plats" do
    plat = plats(:paella)
    assert_respond_to plat, :menus
    assert plat.menus.include?(menus(:weekly_menu))
  end

  test "has many ingredients through plat_ingredients" do
    plat = plats(:paella)
    assert_respond_to plat, :ingredients
    assert plat.ingredients.include?(ingredients(:milk))
  end

  test "destroys menu_plats when plat is destroyed" do
    plat = plats(:paella)
    menu_plats_count = plat.menu_plats.count
    plat_count_before = MenuPlat.count
    plat.destroy
    assert_equal plat_count_before - menu_plats_count, MenuPlat.count
  end

  test "destroys plat_ingredients when plat is destroyed" do
    plat = plats(:paella)
    pi_count = plat.plat_ingredients.count
    pi_count_before = PlatIngredient.count
    plat.destroy
    assert_equal pi_count_before - pi_count, PlatIngredient.count
  end
end
