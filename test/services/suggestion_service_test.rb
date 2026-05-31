require "test_helper"

class SuggestionServiceTest < ActiveSupport::TestCase
  # Fixtures are too sparse to exercise ranking, so these build their own
  # ingredients/dishes. Created ingredients are brand-new, so fixture dishes
  # share zero ingredients with the base and always score below any candidate.

  test "only returns dishes of the same type and never the dish itself" do
    a = Ingredient.create!(name: "sim_a")
    base = dish_with(:segon, [ a ])
    same_type = dish_with(:segon, [ a ])
    other_type = dish_with(:primer, [ a ])

    result = SuggestionService.new(base).alternatives([])

    assert_includes result, same_type
    assert_not_includes result, other_type
    assert_not_includes result, base
  end

  test "ranks candidates by number of shared ingredients, descending" do
    a = Ingredient.create!(name: "sim_a")
    b = Ingredient.create!(name: "sim_b")
    c = Ingredient.create!(name: "sim_c")
    base = dish_with(:segon, [ a, b, c ])
    high = dish_with(:segon, [ a, b, c ]) # shares 3
    mid  = dish_with(:segon, [ a, b ])    # shares 2
    low  = dish_with(:segon, [ a ])       # shares 1

    # high/mid/low are the only same-type dishes sharing >= 1 ingredient,
    # so the top-3 result is exactly them, most similar first.
    assert_equal [ high, mid, low ], SuggestionService.new(base).alternatives([])
  end

  test "excludes dishes carrying any excluded restriction" do
    a = Ingredient.create!(name: "sim_a")
    blocked_ingredient = Ingredient.create!(name: "sim_gluten")
    IngredientRestriction.create!(ingredient: blocked_ingredient, restriction: restrictions(:gluten))

    base = dish_with(:segon, [ a ])
    safe = dish_with(:segon, [ a ])
    blocked = dish_with(:segon, [ a, blocked_ingredient ]) # shares more, but carries gluten

    result = SuggestionService.new(base).alternatives([ restrictions(:gluten) ])

    assert_includes result, safe
    assert_not_includes result, blocked
  end

  test "returns at most three dishes" do
    a = Ingredient.create!(name: "sim_a")
    base = dish_with(:segon, [ a ])
    5.times { dish_with(:segon, [ a ]) }

    assert_equal 3, SuggestionService.new(base).alternatives([]).size
  end

  private

  def dish_with(type, ingredients)
    dish = Dish.create!(name: "sim #{Dish.count}", description: "d", dish_type: type)
    dish.ingredients = ingredients
    dish
  end
end
