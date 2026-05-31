require "test_helper"

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "index requires authentication" do
    sign_out @admin
    get statistics_url
    assert_redirected_to new_user_session_url
  end

  test "index requires admin role" do
    sign_in users(:waiter)
    get statistics_url
    assert_redirected_to root_url
  end

  test "index renders restriction statistics" do
    get statistics_url

    assert_response :success
    assert_includes response.body, restrictions(:gluten).name
    assert_includes response.body, restrictions(:kosher).name
  end

  test "index shows dish and menu counts for each restriction" do
    get statistics_url

    assert_response :success
    assert_match I18n.t("statistics.index.dishes"), response.body
    assert_match I18n.t("statistics.index.menus"), response.body
  end
end
