require "test_helper"

class RestrictionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restriction = restrictions(:one)
    sign_in users(:admin)
  end

  test "should get index" do
    get restrictions_url
    assert_response :success
  end

  test "should get new" do
    get new_restriction_url
    assert_response :success
  end

  test "should create restriction" do
    assert_difference("Restriction.count") do
      post restrictions_url, params: { restriction: { bg_color: @restriction.bg_color, description: @restriction.description, name: @restriction.name } }
    end

    assert_redirected_to restriction_url(Restriction.last)
  end

  test "should show restriction" do
    get restriction_url(@restriction)
    assert_response :success
  end

  test "should get edit" do
    get edit_restriction_url(@restriction)
    assert_response :success
  end

  test "should update restriction" do
    patch restriction_url(@restriction), params: { restriction: { bg_color: @restriction.bg_color, description: @restriction.description, name: @restriction.name } }
    assert_redirected_to restriction_url(@restriction)
  end

  test "should destroy restriction" do
    assert_difference("Restriction.count", -1) do
      delete restriction_url(@restriction)
    end

    assert_redirected_to restrictions_url
  end
end
