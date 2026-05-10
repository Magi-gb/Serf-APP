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

  test "waiter can access menus index" do
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

  test "edit renders form with menu data" do
    get edit_menu_url(@menu)

    assert_response :success
    assert_includes response.body, @menu.name
    assert_includes response.body, I18n.t("menus.form.name")
  end

  test "edit requires authentication" do
    sign_out @kitchen_manager

    get edit_menu_url(@menu)

    assert_redirected_to new_user_session_url
  end

  test "waiter cannot edit menus" do
    sign_in @waiter

    get edit_menu_url(@menu)

    assert_redirected_to root_path
    assert_equal I18n.t("authorization.not_authorized"), flash[:alert]
  end

  test "waiter cannot update menus" do
    sign_in @waiter

    assert_no_changes -> { @menu.reload.name } do
      patch menu_url(@menu), params: {
        menu: {
          name: "Menú Premium"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "update changes menu name" do
    patch menu_url(@menu), params: {
      menu: {
        name: "Menú Premium"
      }
    }

    assert_redirected_to menus_url
    assert_equal I18n.t("menus.messages.updated_success"), flash[:notice]
    assert_equal "Menú Premium", @menu.reload.name
  end

  test "update with invalid params re-renders form" do
    patch menu_url(@menu), params: {
      menu: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
    assert_equal "Menú setmanal", @menu.reload.name
  end

  test "update requires authentication" do
    sign_out @kitchen_manager

    patch menu_url(@menu), params: {
      menu: {
        name: "Menú Premium"
      }
    }

    assert_redirected_to new_user_session_url
  end

  test "admin can edit and update menus" do
    sign_in @admin

    get edit_menu_url(@menu)
    assert_response :success

    patch menu_url(@menu), params: {
      menu: {
        name: "Menú Admin"
      }
    }

    assert_redirected_to menus_url
    assert_equal "Menú Admin", @menu.reload.name
  end

  test "show displays menu plats" do
  menu = menus(:weekly_menu)
  get menu_url(menu)
  assert_response :success
  # Verify plats are displayed (assuming you have paella in weekly_menu)
  assert_select "a", { text: "Paella" }
  end

  test "waiter can access show" do
    sign_in @waiter

    get menu_url(@menu)

    assert_response :success
    assert_includes response.body, @menu.name
  end

  test "can create menu with plats" do
    post menus_url, params: {
      menu: {
        name: "New menu with plats",
        plat_ids: [ plats(:paella).id, plats(:olivas).id ]
      }
    }

    menu = Menu.last
    assert_equal 2, menu.plats.count
  end

  test "can update menu plats" do
    menu = menus(:weekly_menu)
    patch menu_url(menu), params: {
      menu: {
        name: menu.name,
        plat_ids: [ plats(:olivas).id ]  # Remove paella, keep olivas
      }
    }

    assert_equal 1, menu.reload.plats.count
    assert menu.plats.include?(plats(:olivas))
  end
end
