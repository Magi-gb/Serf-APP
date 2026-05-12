require "test_helper"

class DishesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @admin = users(:admin)

    @dish = dishes(:paella)
    sign_in @kitchen_manager
  end

  test "index requires authentication" do
    sign_out @kitchen_manager
    get dishes_url
    assert_redirected_to new_user_session_url
  end

  test "waiter can access index" do
    sign_in @waiter
    get dishes_url
    assert_response :success
  end

  test "waiter can access show" do
    sign_in @waiter
    get dish_url(@dish)
    assert_response :success
  end

  test "waiter cannot access new" do
    sign_in @waiter
    get new_dish_url
    assert_redirected_to root_url
  end

  test "waiter cannot access edit" do
    sign_in @waiter
    get edit_dish_url(@dish)
    assert_redirected_to root_url
  end

  test "kitchen manager can access index" do
    get dishes_url
    assert_response :success
  end

  test "kitchen manager can access show" do
    get dish_url(@dish)
    assert_response :success
  end

  test "kitchen manager can access new" do
    get new_dish_url
    assert_response :success
  end

  test "kitchen manager can access edit" do
    get edit_dish_url(@dish)
    assert_response :success
  end

  test "admin can access everything" do
    sign_in @admin
    get dishes_url
    assert_response :success

    get new_dish_url
    assert_response :success

    get edit_dish_url(@dish)
    assert_response :success
  end

  test "create stores a dish" do
    assert_difference "Dish.count", 1 do
      post dishes_url, params: {
        dish: {
          name: "Escalivada",
          description: "Verdures rostides",
          dish_type: "entrant"
        }
      }
    end

    assert_redirected_to dish_url(Dish.last)
    assert_equal I18n.t("dishes.messages.created_success"), flash[:notice]
  end

  test "create with ingredients stores dish with associations" do
    ingredient = ingredients(:milk)

    assert_difference "Dish.count", 1 do
      post dishes_url, params: {
        dish: {
          name: "Salad",
          description: "Fresh salad",
          dish_type: "entrant",
          ingredient_ids: [ ingredient.id ]
        }
      }
    end

    dish = Dish.last
    assert_equal 1, dish.ingredients.count
    assert_includes dish.ingredients, ingredient
  end

  test "create with invalid params re-renders form" do
    assert_no_difference "Dish.count" do
      post dishes_url, params: {
        dish: {
          name: "",
          description: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "update changes dish name" do
    patch dish_url(@dish), params: {
      dish: {
        name: "Paella Valenciana"
      }
    }

    assert_redirected_to dish_url(@dish)
    assert_equal I18n.t("dishes.messages.updated_success"), flash[:notice]
    assert_equal "Paella Valenciana", @dish.reload.name
  end

  test "update changes dish_type" do
    patch dish_url(@dish), params: {
      dish: {
        name: @dish.name,
        dish_type: "segon"
      }
    }

    assert_redirected_to dish_url(@dish)
    assert_equal "segon", @dish.reload.dish_type
  end

  test "update changes dish description" do
    new_description = "Arroz con verduras y mariscos"

    patch dish_url(@dish), params: {
      dish: {
        name: @dish.name,
        description: new_description
      }
    }

    assert_redirected_to dish_url(@dish)
    assert_equal new_description, @dish.reload.description
  end

  test "update changes dish ingredients" do
    ingredient = ingredients(:milk)

    assert_no_difference "DishIngredient.count" do
      patch dish_url(@dish), params: {
        dish: {
          name: @dish.name,
          ingredient_ids: [ ingredient.id ]
        }
      }
    end

    assert_includes @dish.reload.ingredients, ingredient
  end

  test "update with invalid params re-renders form" do
    original_name = @dish.name

    patch dish_url(@dish), params: {
      dish: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @dish.reload.name
  end

  test "destroy removes a dish" do
    dish = dishes(:olivas)

    assert_difference "Dish.count", -1 do
      delete dish_url(dish)
    end

    assert_redirected_to dishes_url
    assert_equal I18n.t("dishes.messages.destroyed_success"), flash[:notice]
  end

  test "waiter cannot create dishes" do
    sign_in @waiter

    assert_no_difference "Dish.count" do
      post dishes_url, params: {
        dish: {
          name: "Test Dish",
          description: "Test"
        }
      }
    end

    assert_redirected_to root_url
  end

  test "waiter cannot update dishes" do
    sign_in @waiter

    assert_no_changes -> { @dish.reload.name } do
      patch dish_url(@dish), params: {
        dish: {
          name: "Updated Name"
        }
      }
    end

    assert_redirected_to root_url
  end

  test "waiter cannot destroy dishes" do
    sign_in @waiter

    assert_no_difference "Dish.count" do
      delete dish_url(@dish)
    end

    assert_redirected_to root_url
  end

  test "update requires authentication" do
    sign_out @kitchen_manager

    patch dish_url(@dish), params: {
      dish: {
        name: "Updated"
      }
    }

    assert_redirected_to new_user_session_url
  end

  test "destroy requires authentication" do
    sign_out @kitchen_manager

    delete dish_url(@dish)

    assert_redirected_to new_user_session_url
  end

  test "index with dish_types filter shows dishes" do
    get dishes_url, params: { dish_types: [ "entrant" ] }
    assert_response :success
  end

  test "index without filter shows all dishes" do
    get dishes_url
    assert_response :success
  end

  test "index with include_restrictions filter shows response" do
    get dishes_url, params: { include_restrictions: [ "1" ] }
    assert_response :success
  end

  test "index with exclude_restrictions filter shows response" do
    get dishes_url, params: { exclude_restrictions: [ "1" ] }
    assert_response :success
  end

  test "index with combined filters shows response" do
    get dishes_url, params: {
      dish_types: [ "entrant" ],
      include_restrictions: [ "1" ],
      exclude_restrictions: [ "2" ]
    }
    assert_response :success
  end
end
