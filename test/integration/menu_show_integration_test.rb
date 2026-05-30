require "test_helper"

class MenuShowIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @menu = menus(:weekly_menu)
  end

  test "waiter can see expandable dish cards" do
    sign_in @waiter

    get menu_path(@menu)

    assert_response :success
    @menu.dishes.each do |dish|
      assert_includes response.body, "menu-dish-card"
      assert_includes response.body, dish.name
    end
  end

  test "waiter can see restriction toggles" do
    sign_in @waiter
    dish = @menu.dishes.first
    restrictions = dish.ingredients.flat_map(&:restrictions).uniq

    skip "Dish has no restrictions" if restrictions.empty?

    get menu_path(@menu)

    assert_response :success
    restrictions.each do |r|
      assert_includes response.body, r.name
    end
  end

  test "waiter can see alternatives radio buttons" do
    sign_in @waiter
    dish = @menu.dishes.first
    restrictions = dish.ingredients.flat_map(&:restrictions).uniq

    skip "Dish has no restrictions" if restrictions.empty?

    get menu_path(@menu)

    assert_response :success
    assert_includes response.body, 'data-controller="menu-dish-card"'
    assert_includes response.body, "data-menu-dish-card-menu-path-value"
    assert_includes response.body, "dish-alternatives-container"
  end

  test "kitchen manager sees regular dish rows" do
    sign_in @kitchen_manager

    get menu_path(@menu)

    assert_response :success
    @menu.dishes.each do |dish|
      assert_includes response.body, dish.name
    end
  end

  test "admin sees regular dish rows" do
    sign_in @admin

    get menu_path(@menu)

    assert_response :success
    @menu.dishes.each do |dish|
      assert_includes response.body, dish.name
    end
  end

  test "unauthenticated user cannot access menu show" do
    get menu_path(@menu)

    assert_redirected_to new_user_session_url
  end

  test "menu show displays correct number of dishes" do
    sign_in @waiter

    get menu_path(@menu)

    assert_response :success
    assert_match(/#{@menu.dishes.count}/, response.body)
  end
end
