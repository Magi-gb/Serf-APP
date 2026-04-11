require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "has many restrictions through ingredient_restrictions" do
    ingredient = ingredients(:one)
    assert_respond_to ingredient, :restrictions
    assert_respond_to ingredient, :ingredient_restrictions
  end

  test "fixture ingredient has associated restriction" do
    ingredient = ingredients(:one)
    assert_includes ingredient.restrictions, restrictions(:one)
  end

  test "destroying ingredient destroys associated ingredient_restrictions" do
    ingredient = ingredients(:one)
    assert_difference("IngredientRestriction.count", -1) do
      ingredient.destroy
    end
  end

  test "is valid with name and description" do
    ingredient = Ingredient.new(name: "Sal", description: "Sal marina")
    assert ingredient.valid?
  end

  test "is invalid without name" do
    ingredient = Ingredient.new(description: "Some description")
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:name], I18n.t("errors.messages.blank")
  end

  test "is invalid without description" do
    ingredient = Ingredient.new(name: "Sal")
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:description], I18n.t("errors.messages.blank")
  end

  test "is invalid with duplicate name" do
    ingredient = Ingredient.new(name: ingredients(:one).name, description: "Another flour")
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:name], I18n.t("errors.messages.taken")
  end
end
