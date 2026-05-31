require "test_helper"

class MenuCoverageTest < ActiveSupport::TestCase
  # weekly_menu dishes:
  #   olivas  → bread (gluten)
  #   paella  → milk  (no restriction)
  #   salmó   → (no ingredients in fixtures)
  #   gelat   → yogurt (lactose)
  #
  # So weekly_menu has 4 dishes, 2 violated restrictions (gluten×1, lactose×1).

  test "returns only restrictions violated by at least one dish" do
    result = MenuCoverage.new(menus(:weekly_menu)).call
    restriction_names = result.map { |r| r[:restriction].name }

    assert_includes restriction_names, restrictions(:gluten).name
    assert_includes restriction_names, restrictions(:lactose).name
    assert_not_includes restriction_names, restrictions(:kosher).name
  end

  test "violated count equals number of dishes with an ingredient carrying the restriction" do
    result = MenuCoverage.new(menus(:weekly_menu)).call
    gluten_slot = result.find { |r| r[:restriction] == restrictions(:gluten) }

    assert_equal 1, gluten_slot[:violated]
  end

  test "total equals the number of dishes in the menu" do
    result = MenuCoverage.new(menus(:weekly_menu)).call

    result.each do |slot|
      assert_equal menus(:weekly_menu).dishes.size, slot[:total]
    end
  end

  test "returns empty array when no restrictions are violated" do
    # tasting_menu dishes: pan_tomàquet, macarrons, pollastre (salt, no restriction), flan
    result = MenuCoverage.new(menus(:tasting_menu)).call

    assert_empty result
  end

  test "returns empty array when menu has no dishes" do
    menu = Menu.new(name: "Empty")
    assert_empty MenuCoverage.new(menu).call
  end

  test "tag_kind is allergen for intolerance_allergy restrictions" do
    result = MenuCoverage.new(menus(:weekly_menu)).call
    gluten_slot = result.find { |r| r[:restriction] == restrictions(:gluten) }

    assert_equal "allergen", gluten_slot[:tag_kind]
  end

  test "tag_kind is diet for diet restrictions" do
    kosher = restrictions(:kosher)
    ingredient = Ingredient.create!(name: "kosher_ing")
    IngredientRestriction.create!(ingredient: ingredient, restriction: kosher)
    dish = Dish.new(name: "kosher dish", description: "d", dish_type: :entrant)
    dish.ingredients << ingredient
    dish.save!

    menu = Menu.new(name: "Kosher test")
    menu.dishes << dish

    result = MenuCoverage.new(menu).call
    kosher_slot = result.find { |r| r[:restriction] == kosher }

    assert_equal "diet", kosher_slot[:tag_kind]
  end
end
