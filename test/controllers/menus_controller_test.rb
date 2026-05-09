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

  test "waiter can access index" do
    sign_in @waiter

    get menus_url

    assert_response :success
    assert_includes response.body, @menu.name
  end

  test "admin can access index" do
    sign_in @admin

    get menus_url

    assert_response :success
    assert_includes response.body, @menu.name
  end

  test "show displays menu" do
    get menu_url(@menu)

    assert_response :success
    assert_includes response.body, @menu.name
  end

  test "new renders form" do
    get new_menu_url

    assert_response :success
    assert_includes response.body, I18n.t("menus.form.name")
  end

  test "waiter cannot access new" do
    sign_in @waiter

    get new_menu_url

    assert_redirected_to root_path
    assert_equal I18n.t("authorization.not_authorized"), flash[:alert]
  end

  test "create stores a menu" do
    assert_difference "Menu.count", 1 do
      post menus_url, params: {
        menu: {
          name: "Menú Gourmet"
        }
      }
    end

    assert_redirected_to menu_url(Menu.last)
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

  test "edit renders form" do
    get edit_menu_url(@menu)

    assert_response :success
    assert_includes response.body, I18n.t("menus.edit.title")
  end

  test "waiter cannot access edit" do
    sign_in @waiter

    get edit_menu_url(@menu)

    assert_redirected_to root_path
    assert_equal I18n.t("authorization.not_authorized"), flash[:alert]
  end

  test "update modifies a menu" do
    patch menu_url(@menu), params: {
      menu: {
        name: "Menú Updated"
      }
    }

    assert_redirected_to menu_url(@menu)
    assert_equal I18n.t("menus.messages.updated_success"), flash[:notice]
    @menu.reload
    assert_equal "Menú Updated", @menu.name
  end

  test "update with invalid params re-renders form" do
    patch menu_url(@menu), params: {
      menu: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
  end

  test "destroy removes a menu" do
    menu = menus(:tasting_menu)

    assert_difference "Menu.count", -1 do
      delete menu_url(menu)
    end

    assert_redirected_to menus_url
    assert_equal I18n.t("menus.messages.destroyed_success"), flash[:notice]
  end

  test "waiter cannot delete menus" do
    sign_in @waiter

    assert_no_difference "Menu.count" do
      delete menu_url(@menu)
    end

    assert_redirected_to root_path
    assert_equal I18n.t("authorization.not_authorized"), flash[:alert]
  end
end
