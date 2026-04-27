require "test_helper"

class PostLoginRedirectTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin logs in and lands on dashboard" do
    post user_session_path, params: { user: { username: "admin", password: "password" } }
    assert_redirected_to root_path
  end

  test "waiter logs in and lands on root" do
    post user_session_path, params: { user: { username: "waiter", password: "password" } }
    assert_redirected_to root_path
  end

  test "kitchen manager logs in and lands on root" do
    post user_session_path, params: { user: { username: "kitchen_manager", password: "password" } }
    assert_redirected_to root_path
  end

  test "sidebar shows Personal link for admin" do
    sign_in users(:admin)
    get users_path
    assert_response :success
    assert_match I18n.t("sidebar.personal"), response.body
  end

  test "sidebar hides Personal link for waiter" do
    sign_in users(:waiter)
    get root_path
    assert_response :success
    assert_no_match I18n.t("sidebar.personal"), response.body
  end
end
