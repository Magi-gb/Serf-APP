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

  test "index is accessible to kitchen_manager" do
    sign_in users(:kitchen_manager)
    get statistics_url
    assert_response :success
  end

  test "index is accessible to waiter" do
    sign_in users(:waiter)
    get statistics_url
    assert_response :success
  end

  test "index renders restriction names" do
    get statistics_url

    assert_response :success
    assert_includes response.body, restrictions(:gluten).name
    assert_includes response.body, restrictions(:kosher).name
  end

  test "index renders dishes and menus labels" do
    get statistics_url

    assert_response :success
    assert_match I18n.t("statistics.index.dishes"), response.body
    assert_match I18n.t("statistics.index.menus"), response.body
  end

  test "index renders KPI section with safe and total dish counts" do
    get statistics_url

    assert_response :success
    assert_match I18n.t("statistics.index.safe_label"), response.body
    assert_match I18n.t("statistics.index.restricted_label"), response.body
    assert_includes response.body, Dish.safe.count.to_s
    assert_includes response.body, Dish.count.to_s
  end

  test "safe dish count excludes dishes restricted only through elaborations" do
    dish = dishes(:lasanya)
    assert_empty dish.ingredients, "fixture must have no direct ingredients"
    assert dish.elaborations.joins(ingredients: :ingredient_restrictions).exists?,
      "fixture must be restricted via an elaboration"

    buggy_count = Dish.left_joins(ingredients: :ingredient_restrictions)
      .where(ingredient_restrictions: { id: nil }).distinct.count
    assert_not_equal buggy_count, Dish.safe.count,
      "fixtures must distinguish the elaboration path"

    get statistics_url

    assert_response :success
    assert_includes response.body, %(<div class="kpi-number">#{Dish.safe.count}</div>)
    assert_not_includes response.body, %(<div class="kpi-number">#{buggy_count}</div>)
  end

  test "index renders chart titles" do
    get statistics_url

    assert_response :success
    assert_match I18n.t("statistics.index.charts.restrictions_by_dishes"), response.body
    assert_match I18n.t("statistics.index.charts.safe_vs_restricted"), response.body
    assert_match I18n.t("statistics.index.charts.dish_type_distribution"), response.body
    assert_match I18n.t("statistics.index.charts.restrictions_by_type"), response.body
  end

  test "index embeds restriction names in chart JSON data" do
    get statistics_url

    assert_response :success
    assert_includes response.body, restrictions(:gluten).name
  end

  test "index renders dish type labels in distribution chart" do
    get statistics_url

    assert_response :success
    Dish.dish_types.each_key do |type|
      assert_match I18n.t("dishes.types.#{type}"), response.body
    end
  end

  test "index renders restriction type labels in by-type chart" do
    get statistics_url

    assert_response :success
    Restriction.restriction_types.each_key do |type|
      assert_match I18n.t("restrictions.types.#{type}"), response.body
    end
  end
end
