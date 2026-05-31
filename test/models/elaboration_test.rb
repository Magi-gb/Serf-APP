require "test_helper"

class ElaborationTest < ActiveSupport::TestCase
  test "is valid with name and at least one ingredient" do
    elaboration = Elaboration.new(name: "Salsa de tomàquet")
    elaboration.ingredients << ingredients(:milk)
    assert elaboration.valid?
  end

  test "is valid with name, description and at least one ingredient" do
    elaboration = Elaboration.new(name: "Salsa de tomàquet", description: "Tomàquet fregit")
    elaboration.ingredients << ingredients(:milk)
    assert elaboration.valid?
  end

  test "is invalid without name" do
    elaboration = Elaboration.new
    assert_not elaboration.valid?
    assert elaboration.errors[:name].any?
  end

  test "is invalid without ingredients" do
    elaboration = Elaboration.new(name: "Sense ingredients")
    assert_not elaboration.valid?
    assert elaboration.errors[:ingredients].any?
  end

  test "is invalid with duplicate name" do
    duplicate = Elaboration.new(name: "Duplicat")
    duplicate.ingredients << ingredients(:milk)
    duplicate.save!

    elaboration = Elaboration.new(name: "Duplicat")
    elaboration.ingredients << ingredients(:milk)
    assert_not elaboration.valid?
    assert elaboration.errors[:name].any?
  end

  test "has many ingredients through elaboration_ingredients" do
    elaboration = elaborations(:bolognesa)
    assert_respond_to elaboration, :ingredients
    assert_includes elaboration.ingredients, ingredients(:bread)
  end

  test "has many dishes through dish_elaborations" do
    elaboration = elaborations(:bolognesa)
    assert_respond_to elaboration, :dishes
    assert_includes elaboration.dishes, dishes(:lasanya)
  end

  test "destroys elaboration_ingredients when elaboration is destroyed" do
    elaboration = elaborations(:bolognesa)
    count_before = ElaborationIngredient.count
    count_for_this = elaboration.elaboration_ingredients.count
    elaboration.destroy
    assert_equal count_before - count_for_this, ElaborationIngredient.count
  end

  test "destroys dish_elaborations when elaboration is destroyed" do
    elaboration = elaborations(:bolognesa)
    count_before = DishElaboration.count
    count_for_this = elaboration.dish_elaborations.count
    elaboration.destroy
    assert_equal count_before - count_for_this, DishElaboration.count
  end

  test "restrictions aggregates restrictions from all ingredients" do
    elaboration = elaborations(:bolognesa)
    assert_includes elaboration.restrictions, restrictions(:gluten)
  end

  test "restrictions returns empty array when no ingredients have restrictions" do
    elaboration = elaborations(:beixamel)
    assert_empty elaboration.restrictions
  end

  test "search scope filters by name" do
    result = Elaboration.search("bolony")
    assert_includes result, elaborations(:bolognesa)
    assert_not_includes result, elaborations(:beixamel)
  end

  test "search scope returns all when query is blank" do
    assert_equal Elaboration.all.to_a.sort_by(&:id), Elaboration.search("").to_a.sort_by(&:id)
  end

  test "with_restrictions returns elaborations whose ingredients carry the restriction" do
    result = Elaboration.with_restrictions([ restrictions(:gluten).id ])

    assert_includes result, elaborations(:bolognesa)    # bolognesa → bread (gluten)
    assert_not_includes result, elaborations(:beixamel) # beixamel → milk (no restriction)
  end

  test "with_restrictions returns all when ids are empty" do
    assert_equal Elaboration.all.to_a.sort_by(&:id), Elaboration.with_restrictions([]).to_a.sort_by(&:id)
  end

  test "without_restrictions excludes elaborations whose ingredients carry the restriction" do
    result = Elaboration.without_restrictions([ restrictions(:gluten).id ])

    assert_not_includes result, elaborations(:bolognesa)
    assert_includes result, elaborations(:beixamel)
  end

  test "without_restrictions returns all when ids are empty" do
    assert_equal Elaboration.all.to_a.sort_by(&:id), Elaboration.without_restrictions([]).to_a.sort_by(&:id)
  end
end
