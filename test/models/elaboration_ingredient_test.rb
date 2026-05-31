require "test_helper"

class ElaborationIngredientTest < ActiveSupport::TestCase
  test "is valid with elaboration and ingredient" do
    ei = ElaborationIngredient.new(
      elaboration: elaborations(:beixamel),
      ingredient: ingredients(:salt)
    )
    assert ei.valid?
  end

  test "belongs to elaboration" do
    ei = elaboration_ingredients(:bolognesa_bread)
    assert_equal elaborations(:bolognesa), ei.elaboration
  end

  test "belongs to ingredient" do
    ei = elaboration_ingredients(:bolognesa_bread)
    assert_equal ingredients(:bread), ei.ingredient
  end
end
