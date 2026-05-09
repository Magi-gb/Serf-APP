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
end
