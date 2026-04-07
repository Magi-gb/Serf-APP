require "test_helper"

class IngredientRestrictionTest < ActiveSupport::TestCase
  test "belongs_to ingredient" do
    ingredient = Ingredient.create!(name: "Milk #{Time.current.to_i}")
    restriction = Restriction.create!(name: "Gluten #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    ingredient_restriction = IngredientRestriction.create!(ingredient: ingredient, restriction: restriction)

    assert_equal ingredient, ingredient_restriction.ingredient
  end

  test "belongs_to restriction" do
    ingredient = Ingredient.create!(name: "Milk #{Time.current.to_i}")
    restriction = Restriction.create!(name: "Gluten #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    ingredient_restriction = IngredientRestriction.create!(ingredient: ingredient, restriction: restriction)

    assert_equal restriction, ingredient_restriction.restriction
  end

  test "creates association between ingredient and restriction" do
    ingredient = Ingredient.create!(name: "Milk #{Time.current.to_i}")
    restriction = Restriction.create!(name: "Gluten #{Time.current.to_i}", restriction_type: :intolerance_allergy)

    ingredient.restrictions << restriction

    assert ingredient.restrictions.include?(restriction)
    assert restriction.ingredients.include?(ingredient)
  end
end
