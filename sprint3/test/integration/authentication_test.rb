require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "unauthenticated user is redirected to sign in" do
    get root_path
    assert_redirected_to new_user_session_path
  end

  test "sign in with valid credentials" do
    post user_session_path, params: { user: { username: "waiter", password: "password" } }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "sign in with wrong password" do
    post user_session_path, params: { user: { username: "waiter", password: "wrong" } }
    assert_response :unprocessable_content
  end

  test "sign in with nonexistent username" do
    post user_session_path, params: { user: { username: "nobody", password: "password" } }
    assert_response :unprocessable_content
  end

  test "sign out" do
    sign_in users(:waiter)
    delete destroy_user_session_path
    assert_redirected_to root_path
  end

  test "authenticated user can access root" do
    sign_in users(:admin)
    get root_path
    assert_response :success
  end
end
