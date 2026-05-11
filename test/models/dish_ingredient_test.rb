require "test_helper"

class DishIngredientTest < ActiveSupport::TestCase
  test "belongs to dish and ingredient" do
    di = dish_ingredients(:paella_milk)
    assert_equal dishes(:paella), di.dish
    assert_equal ingredients(:milk), di.ingredient
  end

  test "validates uniqueness of dish_id scoped to ingredient_id" do
    existing = dish_ingredients(:paella_milk)
    duplicate = DishIngredient.new(dish_id: existing.dish_id, ingredient_id: existing.ingredient_id)

    assert_not duplicate.valid?
    assert duplicate.errors[:dish_id].any?
  end

  test "requires dish" do
    di = DishIngredient.new(ingredient: ingredients(:milk))
    assert_not di.valid?
    assert di.errors[:dish].any?
  end

  test "requires ingredient" do
    di = DishIngredient.new(dish: dishes(:paella))
    assert_not di.valid?
    assert di.errors[:ingredient].any?
  end
end
