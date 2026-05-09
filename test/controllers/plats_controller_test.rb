require "test_helper"

class PlatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @admin = users(:admin)

    @plat = plats(:paella)
    sign_in @kitchen_manager
  end

  test "index requires authentication" do
    sign_out @kitchen_manager
    get plats_url
    assert_redirected_to new_user_session_url
  end

  test "waiter can access index" do
    sign_in @waiter
    get plats_url
    assert_response :success
  end

  test "waiter can access show" do
    sign_in @waiter
    get plat_url(@plat)
    assert_response :success
  end

  test "waiter cannot access new" do
    sign_in @waiter
    get new_plat_url
    assert_redirected_to root_url
  end

  test "waiter cannot access edit" do
    sign_in @waiter
    get edit_plat_url(@plat)
    assert_redirected_to root_url
  end

  test "kitchen manager can access index" do
    get plats_url
    assert_response :success
  end

  test "kitchen manager can access show" do
    get plat_url(@plat)
    assert_response :success
  end

  test "kitchen manager can access new" do
    get new_plat_url
    assert_response :success
  end

  test "kitchen manager can access edit" do
    get edit_plat_url(@plat)
    assert_response :success
  end

  test "admin can access everything" do
    sign_in @admin
    get plats_url
    assert_response :success

    get new_plat_url
    assert_response :success

    get edit_plat_url(@plat)
    assert_response :success
  end

  test "create stores a plat" do
    assert_difference "Plat.count", 1 do
      post plats_url, params: {
        plat: {
          name: "Fideuà",
          description: "Fideos con caldo",
          tipusPlat: :primer
        }
      }
    end

    assert_redirected_to plat_url(Plat.last)
    assert_equal I18n.t("plats.messages.created_success"), flash[:notice]
  end

  test "create with invalid params re-renders form" do
    assert_no_difference "Plat.count" do
      post plats_url, params: {
        plat: {
          name: "",
          description: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "update modifies a plat" do
    patch plat_url(@plat), params: {
      plat: {
        name: "Paella Updated",
        description: "Arroz con cosas updated",
        tipusPlat: :segon
      }
    }

    assert_redirected_to plat_url(@plat)
    assert_equal I18n.t("plats.messages.updated_success"), flash[:notice]
    @plat.reload
    assert_equal "Paella Updated", @plat.name
  end

  test "update with invalid params re-renders form" do
    patch plat_url(@plat), params: {
      plat: {
        name: "",
        description: ""
      }
    }

    assert_response :unprocessable_entity
  end

  test "destroy removes a plat" do
    plat = plats(:paella)

    assert_difference "Plat.count", -1 do
      delete plat_url(plat)
    end

    assert_redirected_to plats_url
    assert_equal I18n.t("plats.messages.destroyed_success"), flash[:notice]
  end

  test "waiter cannot create plat" do
    sign_in @waiter

    assert_no_difference "Plat.count" do
      post plats_url, params: {
        plat: {
          name: "Test",
          description: "Test",
          tipusPlat: :primer
        }
      }
    end

    assert_redirected_to root_url
  end
end
