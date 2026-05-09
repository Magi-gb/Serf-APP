require "test_helper"

class PlatTest < ActiveSupport::TestCase
  test "has many menus through menu_plats" do
    plat = plats(:paella)
    assert_respond_to plat, :menus
    assert plat.menus.include?(menus(:weekly_menu))
  end

  test "destroys menu_plats when plat is destroyed" do
    plat = plats(:paella)
    menu_plats_count = plat.menu_plats.count
    plat_count_before = MenuPlat.count
    plat.destroy
    assert_equal plat_count_before - menu_plats_count, MenuPlat.count
  end
end
