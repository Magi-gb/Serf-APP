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
    safe_count = Dish.left_joins(ingredients: :ingredient_restrictions)
      .where(ingredient_restrictions: { id: nil }).distinct.count
    assert_includes response.body, safe_count.to_s
    assert_includes response.body, Dish.count.to_s
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

  test "index renders top ingredients chart when ingredients with restrictions exist" do
    get statistics_url

    assert_response :success
    assert_match I18n.t("statistics.index.charts.top_ingredients"), response.body
    top_ingredient = Ingredient.joins(:ingredient_restrictions).group(:name).count.max_by(&:last)
    assert_includes response.body, top_ingredient.first if top_ingredient
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
