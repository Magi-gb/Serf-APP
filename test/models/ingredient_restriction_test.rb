require "test_helper"

class IngredientRestrictionTest < ActiveSupport::TestCase
  test "belongs to ingredient" do
    ir = ingredient_restrictions(:one)
    assert_equal ingredients(:one), ir.ingredient
  end

  test "belongs to restriction" do
    ir = ingredient_restrictions(:one)
    assert_equal restrictions(:one), ir.restriction
  end

  test "is invalid without ingredient" do
    ir = IngredientRestriction.new(restriction: restrictions(:one))
    assert_not ir.valid?
  end

  test "is invalid without restriction" do
    ir = IngredientRestriction.new(ingredient: ingredients(:one))
    assert_not ir.valid?
  end
end
