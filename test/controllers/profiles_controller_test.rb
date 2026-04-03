require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @waiter = users(:waiter)
    sign_in @waiter
  end

  test "show displays current user profile" do
    get profile_path
    assert_response :success
    assert_match @waiter.username, response.body
  end

  test "edit renders password form" do
    get edit_profile_path
    assert_response :success
  end

  test "update with correct current password changes password" do
    patch profile_path, params: { profile: { current_password: "password", password: "newpassword", password_confirmation: "newpassword" } }
    assert_redirected_to profile_path
    assert_equal I18n.t("profile.update.success"), flash[:notice]
    assert @waiter.reload.valid_password?("newpassword")
  end

  test "update with wrong current password re-renders with error" do
    patch profile_path, params: { profile: { current_password: "wrong", password: "newpassword", password_confirmation: "newpassword" } }
    assert_response :unprocessable_entity
  end

  test "all roles can access profile" do
    [ users(:admin), users(:kitchen_manager), users(:waiter) ].each do |user|
      sign_in user
      get profile_path
      assert_response :success
    end
  end
end
