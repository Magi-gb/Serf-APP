require "test_helper"

class IngredientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ingredient = ingredients(:one)
    sign_in users(:admin)
  end

  test "should get index" do
    get ingredients_url
    assert_response :success
  end

  test "should get new" do
    get new_ingredient_url
    assert_response :success
  end

  test "should create ingredient" do
    assert_difference("Ingredient.count") do
      post ingredients_url, params: { ingredient: { name: "Tomàquet", description: "Tomàquet madur" } }
    end

    assert_redirected_to ingredient_url(Ingredient.last)
  end

  test "should show ingredient" do
    get ingredient_url(@ingredient)
    assert_response :success
  end

  test "should get edit" do
    get edit_ingredient_url(@ingredient)
    assert_response :success
  end

  test "should update ingredient" do
    patch ingredient_url(@ingredient), params: { ingredient: { name: @ingredient.name, description: @ingredient.description } }
    assert_redirected_to ingredient_url(@ingredient)
  end

  test "should destroy ingredient" do
    assert_difference("Ingredient.count", -1) do
      delete ingredient_url(@ingredient)
    end

    assert_redirected_to ingredients_url
  end

  test "unauthenticated user should be redirected" do
    sign_out users(:admin)
    get ingredients_url
    assert_response :redirect
  end

  test "waiter can access index" do
    sign_in users(:waiter)
    get ingredients_url
    assert_response :success
  end

  test "waiter can access show" do
    sign_in users(:waiter)
    get ingredient_url(@ingredient)
    assert_response :success
  end

  test "waiter cannot create ingredient" do
    sign_in users(:waiter)
    assert_no_difference("Ingredient.count") do
      post ingredients_url, params: { ingredient: { name: "Sal", description: "Sal marina" } }
    end
    assert_redirected_to root_url
  end

  test "waiter cannot update ingredient" do
    sign_in users(:waiter)
    patch ingredient_url(@ingredient), params: { ingredient: { name: "Changed" } }
    assert_redirected_to root_url
  end

  test "waiter cannot destroy ingredient" do
    sign_in users(:waiter)
    assert_no_difference("Ingredient.count") do
      delete ingredient_url(@ingredient)
    end
    assert_redirected_to root_url
  end

  test "kitchen manager can create ingredient" do
    sign_in users(:kitchen_manager)
    assert_difference("Ingredient.count") do
      post ingredients_url, params: { ingredient: { name: "Pebre", description: "Pebre negre" } }
    end
    assert_redirected_to ingredient_url(Ingredient.last)
  end
end
