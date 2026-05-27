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

  # ---- restriction filter scopes ----

  test "with_restrictions returns menus containing a matching restriction" do
    result = Menu.with_restrictions([ restrictions(:gluten).id ])

    assert_includes result, menus(:weekly_menu)
    assert_not_includes result, menus(:tasting_menu)
  end

  test "with_restrictions returns ::all when ids are empty or nil" do
    assert_equal Menu.all.to_a.sort_by(&:id), Menu.with_restrictions([]).to_a.sort_by(&:id)
    assert_equal Menu.all.to_a.sort_by(&:id), Menu.with_restrictions(nil).to_a.sort_by(&:id)
  end

  test "with_restrictions is distinct (a menu touching multiple matching ingredients appears once)" do
    # weekly_menu has bread (gluten) via olivas AND yogurt (lactose) via gelat.
    # Asking for both restrictions must still return weekly_menu exactly once.
    result = Menu.with_restrictions([ restrictions(:gluten).id, restrictions(:lactose).id ])

    assert_equal [ menus(:weekly_menu) ], result.to_a
  end

  test "with_restrictions ORs the match across multiple ids" do
    # Lactose alone (not gluten) should still bring in weekly_menu.
    result_lactose_only = Menu.with_restrictions([ restrictions(:lactose).id ])
    assert_includes result_lactose_only, menus(:weekly_menu)

    # Kosher alone matches nothing (no kosher fixtures).
    assert_empty Menu.with_restrictions([ restrictions(:kosher).id ])
  end

  test "without_restrictions excludes menus that touch the listed restrictions" do
    result = Menu.without_restrictions([ restrictions(:gluten).id ])

    assert_not_includes result, menus(:weekly_menu)
    assert_includes result, menus(:tasting_menu)
  end

  test "without_restrictions keeps menus whose ingredients carry no restriction at all" do
    # tasting_menu has pollastre -> salt (salt has no restrictions).
    # Even with a non-empty exclude list, tasting_menu must survive.
    result = Menu.without_restrictions([ restrictions(:gluten).id, restrictions(:lactose).id ])

    assert_includes result, menus(:tasting_menu)
    assert_not_includes result, menus(:weekly_menu)
  end

  test "without_restrictions returns ::all when ids are empty or nil" do
    assert_equal Menu.all.to_a.sort_by(&:id), Menu.without_restrictions([]).to_a.sort_by(&:id)
    assert_equal Menu.all.to_a.sort_by(&:id), Menu.without_restrictions(nil).to_a.sort_by(&:id)
  end
end
