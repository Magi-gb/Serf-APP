require "test_helper"

class MenuPlatTest < ActiveSupport::TestCase
  test "creates a menu_plat with valid attributes" do
    menu = menus(:weekly_menu)
    plat = plats(:paella)

    menu_plat = MenuPlat.new(menu_id: menu.id, plat_id: plat.id)

    assert menu_plat.valid?
  end

  test "validates presence of plat_id" do
    menu = menus(:weekly_menu)

    menu_plat = MenuPlat.new(menu_id: menu.id)

    assert_not menu_plat.valid?
    assert menu_plat.errors[:plat_id].any?
  end

  test "validates uniqueness of plat_id scoped to menu_id" do
    menu = menus(:weekly_menu)
    plat = plats(:paella)

    MenuPlat.create!(menu_id: menu.id, plat_id: plat.id)

    duplicate = MenuPlat.new(menu_id: menu.id, plat_id: plat.id)

    assert_not duplicate.valid?
    assert duplicate.errors[:plat_id].any?
  end
end
