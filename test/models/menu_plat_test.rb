require "test_helper"

class MenuPlatTest < ActiveSupport::TestCase
  test "belongs to menu and plat" do
    menu_plat = menu_plats(:weekly_paella)
    assert_equal menus(:weekly_menu), menu_plat.menu
    assert_equal plats(:paella), menu_plat.plat
  end

  test "validates uniqueness of menu_id scoped to plat_id" do
    existing = menu_plats(:weekly_paella)
    duplicate = MenuPlat.new(menu_id: existing.menu_id, plat_id: existing.plat_id)
    assert_not duplicate.valid?
    assert duplicate.errors[:menu_id].any?
  end
end
