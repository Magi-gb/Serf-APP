require "test_helper"
require "securerandom"

class RestrictionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restriction = restrictions(:one)
  end

  test "should get index" do
    sign_in users(:waiter)
    get restrictions_url
    assert_response :success
  end

  test "should show restriction" do
    sign_in users(:waiter)
    get restriction_url(@restriction)
    assert_response :success
  end

  test "should get new" do
    sign_in users(:kitchen_manager)
    get new_restriction_url
    assert_response :success
  end

  test "should create restriction" do
    sign_in users(:kitchen_manager)

    assert_difference("Restriction.count", 1) do
      post restrictions_url, params: { restriction: {
        bg_color: @restriction.bg_color,
        description: "New restriction description",
        name: "Restriction #{SecureRandom.hex(4)}"
      } }
    end

    assert_redirected_to restriction_url(Restriction.last)
  end

  test "should get edit" do
    sign_in users(:kitchen_manager)
    get edit_restriction_url(@restriction)
    assert_response :success
  end

  test "should update restriction" do
    sign_in users(:kitchen_manager)

    patch restriction_url(@restriction), params: { restriction: {
      bg_color: @restriction.bg_color,
      description: @restriction.description,
      name: "Updated #{SecureRandom.hex(4)}"
    } }

    assert_redirected_to restriction_url(@restriction)
  end

  test "should destroy restriction" do
    sign_in users(:kitchen_manager)

    assert_difference("Restriction.count", -1) do
      delete restriction_url(@restriction)
    end

    assert_redirected_to restrictions_url
  end
end
