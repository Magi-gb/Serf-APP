require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "creates a menu with valid name" do
    menu = Menu.new(name: "Menú del día")

    assert menu.valid?
  end

  test "validates presence of name" do
    menu = Menu.new

    assert_not menu.valid?
    assert menu.errors[:name].any?
  end

  test "validates uniqueness of name" do
    Menu.create!(name: "Menú especial")

    duplicate = Menu.new(name: "Menú especial")

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "defines future dish types scaffold for parallel integration" do
    assert_equal %w[starter main dessert], Menu::DISH_TYPES
  end

  test "has many plats through menu_plats" do
    menu = menus(:weekly_menu)
    assert_respond_to menu, :plats
    assert menu.plats.include?(plats(:paella))
  end

  test "destroys menu_plats when menu is destroyed" do
    menu = menus(:weekly_menu)
    menu_plats_count = menu.menu_plats.count
    plat_count_before = MenuPlat.count
    menu.destroy
    assert_equal plat_count_before - menu_plats_count, MenuPlat.count
  end

  test "can add plats to menu" do
    menu = Menu.create!(name: "Test menu")
    plat = plats(:paella)
    menu.plats << plat
    assert menu.plats.include?(plat)
  end
end
