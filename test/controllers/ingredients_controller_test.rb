require "test_helper"

class IngredientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @admin = users(:admin)
    sign_in @kitchen_manager
  end

  test "index requires authentication" do
    sign_out @kitchen_manager
    get ingredients_url
    assert_redirected_to new_user_session_url
  end

  test "waiter can access index" do
    sign_in @waiter
    get ingredients_url
    assert_response :success
  end

  test "index displays ingredients" do
    Ingredient.create!(name: "Milk #{Time.current.to_i}")
    get ingredients_url
    assert_response :success
  end

  test "new renders form" do
    get new_ingredient_url
    assert_response :success
    assert_includes response.body, "form"
  end

  test "create stores ingredient" do
    assert_difference "Ingredient.count", 1 do
      post ingredients_url, params: {
        ingredient: {
          name: "Milk #{Time.current.to_i}"
        }
      }
    end
    assert_redirected_to ingredients_url
  end

  test "create with restrictions" do
    restriction = Restriction.create!(name: "Gluten #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    post ingredients_url, params: {
      ingredient: {
        name: "Bread #{Time.current.to_i}",
        restriction_ids: [restriction.id]
      }
    }
    ingredient = Ingredient.last
    assert ingredient.restrictions.include?(restriction)
  end

  test "show displays ingredient" do
    ingredient = Ingredient.create!(name: "Milk #{Time.current.to_i}")
    get ingredient_url(ingredient)
    assert_response :success
    assert_includes response.body, ingredient.name
  end

  test "edit renders form" do
    ingredient = Ingredient.create!(name: "Milk #{Time.current.to_i}")
    get edit_ingredient_url(ingredient)
    assert_response :success
  end

  test "update modifies ingredient" do
    ingredient = Ingredient.create!(name: "Milk #{Time.current.to_i}")
    new_name = "Butter #{Time.current.to_i}"
    patch ingredient_url(ingredient), params: {
      ingredient: {
        name: new_name
      }
    }
    ingredient.reload
    assert_equal new_name, ingredient.name
    assert_redirected_to ingredients_url
  end

  test "destroy removes ingredient" do
    ingredient = Ingredient.create!(name: "Milk #{Time.current.to_i}")
    assert_difference "Ingredient.count", -1 do
      delete ingredient_url(ingredient)
    end
    assert_redirected_to ingredients_url
  end
end
