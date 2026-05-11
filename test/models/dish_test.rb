require "test_helper"

class DishTest < ActiveSupport::TestCase
  test "is valid with name, description and dish_type" do
    dish = Dish.new(name: "Test Dish", description: "Test description", dish_type: :entrant)
    assert dish.valid?
  end

  test "validates presence of name" do
    dish = Dish.new(description: "Test", dish_type: :entrant)
    assert_not dish.valid?
    assert dish.errors[:name].any?
  end

  test "validates presence of description" do
    dish = Dish.new(name: "Test", dish_type: :entrant)
    assert_not dish.valid?
    assert dish.errors[:description].any?
  end

  test "rejects invalid dish_type values" do
    assert_raises(ArgumentError) do
      Dish.new(name: "Test", description: "Test", dish_type: :invalid_type)
    end
  end

  test "accepts all enum values for dish_type" do
    %i[entrant primer segon postre].each do |type|
      dish = Dish.new(name: "Dish #{type}", description: "d", dish_type: type)
      assert_equal type.to_s, dish.dish_type
    end
  end

  test "strips whitespace from name before validation" do
    dish = Dish.new(name: "  Paella  ", description: "Test", dish_type: :primer)
    dish.valid?
    assert_equal "Paella", dish.name
  end

  test "has many menus through menu_dishes" do
    dish = dishes(:paella)
    assert_respond_to dish, :menus
    assert dish.menus.include?(menus(:weekly_menu))
  end

  test "has many ingredients through dish_ingredients" do
    dish = dishes(:paella)
    assert_respond_to dish, :ingredients
    assert dish.ingredients.include?(ingredients(:milk))
  end

  test "destroys menu_dishes when dish is destroyed" do
    dish = dishes(:paella)
    menu_dishes_count = dish.menu_dishes.count
    md_count_before = MenuDish.count
    dish.destroy
    assert_equal md_count_before - menu_dishes_count, MenuDish.count
  end

  test "destroys dish_ingredients when dish is destroyed" do
    dish = dishes(:paella)
    di_count = dish.dish_ingredients.count
    di_count_before = DishIngredient.count
    dish.destroy
    assert_equal di_count_before - di_count, DishIngredient.count
  end
end
