require "test_helper"

class IngredientAlternativeTest < ActiveSupport::TestCase
  test "valid when alternative does not add restrictions" do
    bread = ingredients(:bread)
    milk = ingredients(:milk)

    ingredient_alternative = IngredientAlternative.new(ingredient: bread, alternative: milk)
    assert ingredient_alternative.valid?
  end

  test "invalid when alternative adds restrictions not present in ingredient" do
    bread = ingredients(:bread)
    kosher = restrictions(:kosher)

    pork = Ingredient.create!(name: "Pork #{Time.current.to_i}")
    IngredientRestriction.create!(ingredient: pork, restriction: kosher)

    ingredient_alternative = IngredientAlternative.new(ingredient: bread, alternative: pork)
    assert_not ingredient_alternative.valid?
    assert ingredient_alternative.errors[:alternative].any?
  end
end
