require "test_helper"

class MenuDishTest < ActiveSupport::TestCase
  test "belongs to menu and dish" do
    menu_dish = menu_dishes(:weekly_entrant)
    assert_equal menus(:weekly_menu), menu_dish.menu
    assert_equal dishes(:olivas), menu_dish.dish
  end

  test "validates uniqueness of menu_id scoped to dish_id" do
    existing = menu_dishes(:weekly_entrant)
    duplicate = MenuDish.new(menu_id: existing.menu_id, dish_id: existing.dish_id)
    assert_not duplicate.valid?
    assert duplicate.errors[:menu_id].any?
  end
end
