require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @menu = menus(:weekly_menu)
    sign_in @kitchen_manager
  end

  test "index requires authentication" do
    sign_out @kitchen_manager

    get menus_url

    assert_redirected_to new_user_session_url
  end

  test "waiter cannot access menus" do
    sign_in @waiter

    get menus_url

    assert_redirected_to root_path
    assert_equal I18n.t("authorization.not_authorized"), flash[:alert]
  end

  test "admin can access index" do
    sign_in @admin

    get menus_url

    assert_response :success
    assert_includes response.body, @menu.name
  end

  test "new renders form" do
    get new_menu_url

    assert_response :success
    assert_includes response.body, I18n.t("menus.form.name")
  end

  test "create stores a menu" do
    assert_difference "Menu.count", 1 do
      post menus_url, params: {
        menu: {
          name: "Menú Gourmet"
        }
      }
    end

    assert_redirected_to menus_url
    assert_equal I18n.t("menus.messages.created_success"), flash[:notice]
  end

  test "create with invalid params re-renders form" do
    assert_no_difference "Menu.count" do
      post menus_url, params: {
        menu: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "destroy removes a menu" do
    menu = menus(:tasting_menu)

    assert_difference "Menu.count", -1 do
      delete menu_url(menu)
    end

    assert_redirected_to menus_url
  end

  test "waiter cannot delete menus" do
    sign_in @waiter

    assert_no_difference "Menu.count" do
      delete menu_url(@menu)
    end

    assert_redirected_to root_path
  end
end
