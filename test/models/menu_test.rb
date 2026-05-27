require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "creates a menu with valid name and dishes" do
    dish_ids = [ dishes(:olivas).id, dishes(:paella).id, dishes(:salmó).id, dishes(:gelat).id ]
    menu = Menu.new(name: "Menú del día", dish_ids: dish_ids)

    assert menu.valid?
  end

  test "validates presence of name" do
    menu = Menu.new

    assert_not menu.valid?
    assert menu.errors[:name].any?
  end

  test "validates uniqueness of name" do
    Menu.create!(name: "Menú especial", dish_ids: [ dishes(:olivas).id, dishes(:paella).id, dishes(:salmó).id, dishes(:gelat).id ])

    duplicate = Menu.new(name: "Menú especial")

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "requires one dish of each type" do
    menu = Menu.new(name: "Menú incompleto", dish_ids: [ dishes(:olivas).id, dishes(:paella).id ])
    assert_not menu.valid?
    assert menu.errors[:base].any?
  end

  test "has many dishes through menu_dishes" do
    menu = menus(:weekly_menu)
    assert_respond_to menu, :dishes
    assert_equal 4, menu.dishes.count
  end

  test "destroys menu_dishes when menu is destroyed" do
    menu = menus(:weekly_menu)
    menu_dishes_count = menu.menu_dishes.count
    md_count_before = MenuDish.count
    menu.destroy
    assert_equal md_count_before - menu_dishes_count, MenuDish.count
  end

  test "can add dishes to menu" do
    menu = Menu.create!(name: "Test menu", dish_ids: [ dishes(:olivas).id, dishes(:paella).id, dishes(:salmó).id, dishes(:gelat).id ])
    assert menu.dishes.include?(dishes(:paella))
  end

  # --- without_restrictions scope ---

  test "without_restrictions with empty ids returns all menus" do
    result = Menu.without_restrictions([])
    assert_includes result, menus(:weekly_menu)
    assert_includes result, menus(:tasting_menu)
  end

  test "without_restrictions with nil returns all menus" do
    result = Menu.without_restrictions(nil)
    assert_includes result, menus(:weekly_menu)
    assert_includes result, menus(:tasting_menu)
  end

  test "without_restrictions excludes menus that contain the restriction" do
    # weekly_menu has olivas → bread → gluten
    result = Menu.without_restrictions([ restrictions(:gluten).id ])
    assert_not_includes result, menus(:weekly_menu)
    assert_includes result, menus(:tasting_menu)
  end

  test "without_restrictions keeps menus that do not contain the restriction" do
    # no menu has the kosher restriction in any ingredient
    result = Menu.without_restrictions([ restrictions(:kosher).id ])
    assert_includes result, menus(:weekly_menu)
    assert_includes result, menus(:tasting_menu)
  end
end
