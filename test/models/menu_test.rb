require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "creates a menu with valid name and plats" do
    plats_ids = [ plats(:olivas).id, plats(:paella).id, plats(:salmó).id, plats(:gelat).id ]
    menu = Menu.new(name: "Menú del día", plat_ids: plats_ids)

    assert menu.valid?
  end

  test "validates presence of name" do
    menu = Menu.new

    assert_not menu.valid?
    assert menu.errors[:name].any?
  end

  test "validates uniqueness of name" do
    Menu.create!(name: "Menú especial", plat_ids: [ plats(:olivas).id, plats(:paella).id, plats(:salmó).id, plats(:gelat).id ])

    duplicate = Menu.new(name: "Menú especial")

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "requires one plat of each type" do
    menu = Menu.new(name: "Menú incompleto", plat_ids: [ plats(:olivas).id, plats(:paella).id ])
    assert_not menu.valid?
    assert menu.errors[:base].any?
  end

  test "has many plats through menu_plats" do
    menu = menus(:weekly_menu)
    assert_respond_to menu, :plats
    assert_equal 4, menu.plats.count
  end

  test "destroys menu_plats when menu is destroyed" do
    menu = menus(:weekly_menu)
    menu_plats_count = menu.menu_plats.count
    plat_count_before = MenuPlat.count
    menu.destroy
    assert_equal plat_count_before - menu_plats_count, MenuPlat.count
  end

  test "can add plats to menu" do
    menu = Menu.create!(name: "Test menu", plat_ids: [ plats(:olivas).id, plats(:paella).id, plats(:salmó).id, plats(:gelat).id ])
    assert menu.plats.include?(plats(:paella))
  end
end
