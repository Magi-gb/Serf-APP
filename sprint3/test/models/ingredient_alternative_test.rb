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

  test "invalid when alternative is the same as ingredient" do
    bread = ingredients(:bread)

    ingredient_alternative = IngredientAlternative.new(ingredient: bread, alternative: bread)
    assert_not ingredient_alternative.valid?
    assert ingredient_alternative.errors[:alternative].any?
  end

  test "invalid when the same alternative is added twice" do
    bread = ingredients(:bread)
    milk = ingredients(:milk)
    IngredientAlternative.create!(ingredient: bread, alternative: milk)

    duplicate = IngredientAlternative.new(ingredient: bread, alternative: milk)
    assert_not duplicate.valid?
    assert duplicate.errors[:alternative_id].any?
  end

  test "destroying an ingredient also removes rows that reference it as alternative" do
    bread = ingredients(:bread)
    milk = ingredients(:milk)
    IngredientAlternative.create!(ingredient: bread, alternative: milk)

    assert_difference("IngredientAlternative.count", -1) do
      milk.destroy
    end
  end
end
