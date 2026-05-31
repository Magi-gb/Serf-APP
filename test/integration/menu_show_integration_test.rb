require "test_helper"

class MenuShowIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @menu = menus(:weekly_menu)
  end

  # The dish card is unified: every role sees the same interactive card
  # (stretched link to the dish + toggleable restriction tags).
  test "every role sees the same interactive dish card" do
    [ @waiter, @kitchen_manager, @admin ].each do |user|
      sign_in user
      get menu_path(@menu)

      assert_response :success
      assert_includes response.body, 'class="menu-dish-item"'
      assert_includes response.body, "stretched-link"
      @menu.dishes.each do |dish|
        assert_includes response.body, dish.name
        assert_includes response.body, dish_path(dish)
      end

      sign_out user
    end
  end

  test "waiter can see restriction tags" do
    sign_in @waiter
    dish = @menu.dishes.first
    restrictions = dish.ingredients.flat_map(&:restrictions).uniq

    skip "Dish has no restrictions" if restrictions.empty?

    get menu_path(@menu)

    assert_response :success
    restrictions.each do |r|
      assert_includes response.body, r.name
    end
    assert_includes response.body, 'class="tag tag-'
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
