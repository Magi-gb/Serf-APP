require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @waiter = users(:waiter)
    @kitchen_manager = users(:kitchen_manager)
    sign_in @admin
  end

  # --- Admin access (happy path) ---

  test "index lists all users" do
    get users_path
    assert_response :success
  end

  test "index with search param filters users" do
    get users_path, params: { search: "admin" }
    assert_response :success
    assert_match "admin", response.body
    assert_no_match "waiter", response.body
  end

  test "show displays user" do
    get user_path(@waiter)
    assert_response :success
    assert_match @waiter.username, response.body
  end

  test "new renders form" do
    get new_user_path
    assert_response :success
  end

  test "create with valid params creates user and redirects" do
    assert_difference("User.count") do
      post users_path, params: { user: { username: "newuser", password: "password", password_confirmation: "password", role: "waiter" } }
    end
    assert_redirected_to users_path
    assert_equal I18n.t("users.create.success"), flash[:notice]
  end

  test "create with invalid params re-renders form" do
    assert_no_difference("User.count") do
      post users_path, params: { user: { username: "", password: "password", role: "waiter" } }
    end
    assert_response :unprocessable_entity
  end

  test "edit renders form" do
    get edit_user_path(@waiter)
    assert_response :success
  end

  test "update with valid params updates user and redirects" do
    patch user_path(@waiter), params: { user: { username: "updated_waiter", role: "waiter" } }
    assert_redirected_to users_path
    assert_equal "updated_waiter", @waiter.reload.username
  end

  test "update without password does not clear password" do
    old_password = @waiter.encrypted_password
    patch user_path(@waiter), params: { user: { username: @waiter.username, password: "", password_confirmation: "" } }
    assert_redirected_to users_path
    assert_equal old_password, @waiter.reload.encrypted_password
  end

  test "update with invalid params re-renders form" do
    patch user_path(@waiter), params: { user: { username: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy deletes user and redirects" do
    assert_difference("User.count", -1) do
      delete user_path(@waiter)
    end
    assert_redirected_to users_path
    assert_equal I18n.t("users.destroy.success"), flash[:notice]
  end

  test "destroy self is rejected" do
    assert_no_difference("User.count") do
      delete user_path(@admin)
    end
    assert_redirected_to users_path
    assert_equal I18n.t("users.destroy.cannot_delete_self"), flash[:alert]
  end

  # --- Authorization (rejection) ---

  test "waiter cannot access users index" do
    sign_in @waiter
    get users_path
    assert_redirected_to root_path
  end

  test "kitchen manager cannot access users index" do
    sign_in @kitchen_manager
    get users_path
    assert_redirected_to root_path
  end

  test "waiter cannot create user" do
    sign_in @waiter
    post users_path, params: { user: { username: "hack", password: "password", role: "admin" } }
    assert_redirected_to root_path
  end

  test "waiter cannot destroy user" do
    sign_in @waiter
    delete user_path(@kitchen_manager)
    assert_redirected_to root_path
  end
end
