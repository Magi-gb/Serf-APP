require "test_helper"

class PlatIngredientTest < ActiveSupport::TestCase
  test "belongs to plat and ingredient" do
    pi = plat_ingredients(:paella_milk)
    assert_equal plats(:paella), pi.plat
    assert_equal ingredients(:milk), pi.ingredient
  end

  test "validates uniqueness of plat_id scoped to ingredient_id" do
    existing = plat_ingredients(:paella_milk)
    duplicate = PlatIngredient.new(plat_id: existing.plat_id, ingredient_id: existing.ingredient_id)

    assert_not duplicate.valid?
    assert duplicate.errors[:plat_id].any?
  end

  test "requires plat" do
    pi = PlatIngredient.new(ingredient: ingredients(:milk))
    assert_not pi.valid?
    assert pi.errors[:plat].any?
  end

  test "requires ingredient" do
    pi = PlatIngredient.new(plat: plats(:paella))
    assert_not pi.valid?
    assert pi.errors[:ingredient].any?
  end
end
