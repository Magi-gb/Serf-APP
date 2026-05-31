require "test_helper"

class RestrictionTest < ActiveSupport::TestCase
  test "creates a restriction with valid attributes" do
    restriction = Restriction.new(name: "Gluten Unique #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    assert restriction.valid?
  end

  test "validates presence of name" do
    restriction = Restriction.new(restriction_type: :intolerance_allergy)
    assert_not restriction.valid?
    assert restriction.errors[:name].any?
  end

  test "validates uniqueness of name" do
    Restriction.create!(name: "Gluten Unique Test #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    restriction = Restriction.new(name: "Gluten Unique Test #{Time.current.to_i}", restriction_type: :diet)
    assert_not restriction.valid?
    assert restriction.errors[:name].any?
  end

  test "validates presence of restriction_type" do
    restriction = Restriction.new(name: "Test #{Time.current.to_i}")
    assert_not restriction.valid?
    assert restriction.errors[:restriction_type].any?
  end

  test "has_many ingredient_restrictions association" do
    assert Restriction.new.respond_to?(:ingredient_restrictions)
  end

  test "has_many ingredients association through ingredient_restrictions" do
    assert Restriction.new.respond_to?(:ingredients)
  end

  test "destroying restriction destroys associated ingredient_restrictions" do
    restriction = restrictions(:gluten)
    assert_difference("IngredientRestriction.count", -1) do
      restriction.destroy
    end
  end

  test "recalculate_all_cached_counts sets ingredients_count from direct links" do
    restrictions(:gluten).recalculate_all_cached_counts!
    assert_equal 1, restrictions(:gluten).reload.ingredients_count
  end

  test "recalculate_all_cached_counts sets elaborations_count via elaboration ingredients" do
    restrictions(:gluten).recalculate_all_cached_counts!
    assert_equal 1, restrictions(:gluten).reload.elaborations_count
  end

  test "recalculate_all_cached_counts sets dishes_count including via elaborations" do
    restrictions(:gluten).recalculate_all_cached_counts!
    # olivas (direct via bread) + lasanya (via bolognesa elaboration)
    assert_equal 2, restrictions(:gluten).reload.dishes_count
  end

  test "recalculate_all_cached_counts sets menus_count through dishes" do
    restrictions(:gluten).recalculate_all_cached_counts!
    # weekly_menu has olivas which has bread (gluten)
    assert_equal 1, restrictions(:gluten).reload.menus_count
  end

  test "creating IngredientRestriction increments ingredients_count" do
    restriction = restrictions(:kosher)
    ingredient = ingredients(:bread)
    assert_difference -> { restriction.reload.ingredients_count } do
      IngredientRestriction.create!(ingredient: ingredient, restriction: restriction)
    end
  end

  test "destroying IngredientRestriction decrements ingredients_count" do
    restriction = restrictions(:gluten)
    assert_difference -> { restriction.reload.ingredients_count }, -1 do
      ingredient_restrictions(:bread_gluten).destroy!
    end
  end

  test "adding DishIngredient updates dishes_count" do
    restriction = restrictions(:kosher)
    restriction.recalculate_all_cached_counts!
    initial = restriction.reload.dishes_count

    bread = ingredients(:bread)
    IngredientRestriction.create!(ingredient: bread, restriction: restriction)
    DishIngredient.create!(dish: dishes(:paella), ingredient: bread)

    assert restriction.reload.dishes_count > initial
  end

  test "destroying DishIngredient updates dishes_count" do
    restrictions(:gluten).recalculate_all_cached_counts!
    before = restrictions(:gluten).reload.dishes_count

    dish_ingredients(:olivas_bread).destroy!

    assert restrictions(:gluten).reload.dishes_count < before
  end

  test "severity defaults to medium" do
    restriction = Restriction.new(name: "Test #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    assert restriction.medium?
  end

  test "accepts low severity" do
    restriction = Restriction.new(name: "Test #{Time.current.to_i}", restriction_type: :diet, severity: :low)
    assert restriction.valid?
    assert restriction.low?
  end

  test "accepts high severity" do
    restriction = Restriction.new(name: "Test #{Time.current.to_i}", restriction_type: :intolerance_allergy, severity: :high)
    assert restriction.valid?
    assert restriction.high?
  end
end
