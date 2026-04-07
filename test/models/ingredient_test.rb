require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "creates an ingredient with valid attributes" do
    ingredient = Ingredient.new(name: "Milk #{Time.current.to_i}")
    assert ingredient.valid?
  end

  test "validates presence of name" do
    ingredient = Ingredient.new
    assert_not ingredient.valid?
    assert ingredient.errors[:name].any?
  end

  test "validates uniqueness of name" do
    unique_name = "Milk #{Time.current.to_i}"
    Ingredient.create!(name: unique_name)
    ingredient = Ingredient.new(name: unique_name)
    assert_not ingredient.valid?
    assert ingredient.errors[:name].any?
  end

  test "has_many ingredient_restrictions association" do
    assert Ingredient.new.respond_to?(:ingredient_restrictions)
  end

  test "has_many restrictions association through ingredient_restrictions" do
    assert Ingredient.new.respond_to?(:restrictions)
  end

  test "search scope returns matching ingredients" do
    milk = Ingredient.create!(name: "Milk Test #{Time.current.to_i}")
    butter = Ingredient.create!(name: "Butter Test #{Time.current.to_i}")

    assert_equal 1, Ingredient.search(milk.name).count
    assert Ingredient.search("Cheese").empty?
  end
end
