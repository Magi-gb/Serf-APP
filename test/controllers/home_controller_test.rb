require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "index requires authentication" do
    sign_out @admin
    get root_url
    assert_redirected_to new_user_session_url
  end

  test "index renders for admin" do
    get root_url
    assert_response :success
  end

  test "index renders for kitchen_manager" do
    sign_in users(:kitchen_manager)
    get root_url
    assert_response :success
  end

  test "index renders for waiter" do
    sign_in users(:waiter)
    get root_url
    assert_response :success
  end

  test "index renders statistics chart titles for all roles" do
    [ users(:admin), users(:kitchen_manager), users(:waiter) ].each do |user|
      sign_in user
      get root_url
      assert_response :success
      assert_match I18n.t("statistics.index.charts.restrictions_by_dishes"), response.body
      assert_match I18n.t("statistics.index.charts.safe_vs_restricted"), response.body
      assert_match I18n.t("statistics.index.charts.restrictions_by_type"), response.body
    end
  end

  test "index renders safe_dishes KPI for all roles" do
    [ users(:admin), users(:kitchen_manager), users(:waiter) ].each do |user|
      sign_in user
      get root_url
      assert_response :success
      assert_match I18n.t("home.index.kpis.safe_dishes"), response.body
    end
  end
end
