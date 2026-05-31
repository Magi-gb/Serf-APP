require "test_helper"

class SuggestionServiceTest < ActiveSupport::TestCase
  # Fixtures are too sparse to exercise ranking, so these build their own
  # ingredients/dishes. Created ingredients are brand-new, so fixture dishes
  # share zero ingredients with the base and always score below any candidate.

  # ---- Filtering (equivalence class partitioning) ----

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

  test "excludes dishes carrying any excluded restriction through a direct ingredient" do
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

  test "excludes candidates carrying an excluded restriction through an elaboration" do
    safe_ingredient = Ingredient.create!(name: "sim_a")
    gluten_ingredient = Ingredient.create!(name: "sim_elab_gluten")
    IngredientRestriction.create!(ingredient: gluten_ingredient, restriction: restrictions(:gluten))

    safe_elaboration = Elaboration.create!(name: "sim safe sauce", ingredients: [ safe_ingredient ])
    gluten_elaboration = Elaboration.create!(name: "sim gluten sauce", ingredients: [ gluten_ingredient ])

    base = dish_with(:segon, [ safe_ingredient ])
    # Carries the restriction only via its elaboration, not a direct ingredient.
    blocked = dish_with(:segon, [ safe_ingredient ], elaborations: [ gluten_elaboration ])
    # Has an elaboration too, but none of its ingredients carry the restriction.
    safe = dish_with(:segon, [ safe_ingredient ], elaborations: [ safe_elaboration ])

    result = SuggestionService.new(base).alternatives([ restrictions(:gluten) ])

    assert_not_includes result, blocked
    assert_includes result, safe
  end

  # ---- Ranking ----

  test "ranks candidates by number of shared ingredients, descending" do
    a = Ingredient.create!(name: "sim_a")
    b = Ingredient.create!(name: "sim_b")
    c = Ingredient.create!(name: "sim_c")
    base = dish_with(:segon, [ a, b, c ])
    high = dish_with(:segon, [ a, b, c ]) # shares 3
    mid  = dish_with(:segon, [ a, b ])    # shares 2
    low  = dish_with(:segon, [ a ])       # shares 1

    # high/mid/low are the only same-type dishes sharing >= 1 ingredient,
    # so they head the result, most similar first.
    result = SuggestionService.new(base).alternatives([])
    assert_equal [ high, mid, low ], result.first(3)
  end

  test "keeps tied candidates together, ahead of less similar dishes" do
    a = Ingredient.create!(name: "sim_a")
    b = Ingredient.create!(name: "sim_b")
    base = dish_with(:segon, [ a, b ])
    tied_one = dish_with(:segon, [ a, b ]) # shares 2
    tied_two = dish_with(:segon, [ a, b ]) # shares 2
    less     = dish_with(:segon, [ a ])    # shares 1

    result = SuggestionService.new(base).alternatives([])

    # sort_by is not stable, so we do not assert an order between the two tied
    # dishes — only that both outrank the less-similar candidate.
    assert_equal [ tied_one, tied_two ].to_set, result.first(2).to_set
    assert_operator result.index(less), :>, result.index(tied_one)
    assert_operator result.index(less), :>, result.index(tied_two)
  end

  # ---- Result-size cap (boundary value analysis, boundary = 5) ----

  test "returns every candidate when fewer than five exist" do
    clear_dishes(:postre)
    shared = Ingredient.create!(name: "sim_shared")
    base = dish_with(:postre, [ shared ])
    candidates = Array.new(4) { dish_with(:postre, [ shared ]) }

    result = SuggestionService.new(base).alternatives([])

    assert_equal 4, result.size
    assert_equal candidates.to_set, result.to_set
  end

  test "returns exactly five when exactly five candidates exist" do
    clear_dishes(:postre)
    shared = Ingredient.create!(name: "sim_shared")
    base = dish_with(:postre, [ shared ])
    Array.new(5) { dish_with(:postre, [ shared ]) }

    assert_equal 5, SuggestionService.new(base).alternatives([]).size
  end

  test "caps the result at five when more than five candidates exist" do
    clear_dishes(:postre)
    shared = Ingredient.create!(name: "sim_shared")
    base = dish_with(:postre, [ shared ])
    Array.new(6) { dish_with(:postre, [ shared ]) }

    assert_equal 5, SuggestionService.new(base).alternatives([]).size
  end

  private

  def dish_with(type, ingredients, elaborations: [])
    dish = Dish.new(name: "sim #{Dish.count}", description: "d", dish_type: type)
    dish.ingredients = ingredients
    dish.elaborations = elaborations
    dish.save!
    dish
  end

  # Removes existing dishes of a type so a boundary test controls the exact
  # number of candidates (fixtures would otherwise inflate the count).
  def clear_dishes(type)
    Dish.where(dish_type: type).destroy_all
  end
end
