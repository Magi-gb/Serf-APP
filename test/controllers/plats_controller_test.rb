require "test_helper"

class PlatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @admin = users(:admin)

    @plat = plats(:paella)
    sign_in @kitchen_manager
  end

  test "index requires authentication" do
    sign_out @kitchen_manager
    get plats_url
    assert_redirected_to new_user_session_url
  end

  test "waiter can access index" do
    sign_in @waiter
    get plats_url
    assert_response :success
  end

  test "waiter can access show" do
    sign_in @waiter
    get plat_url(@plat)
    assert_response :success
  end

  test "waiter cannot access new" do
    sign_in @waiter
    get new_plat_url
    assert_redirected_to root_url
  end

  test "waiter cannot access edit" do
    sign_in @waiter
    get edit_plat_url(@plat)
    assert_redirected_to root_url
  end

  test "kitchen manager can access index" do
    get plats_url
    assert_response :success
  end

  test "kitchen manager can access show" do
    get plat_url(@plat)
    assert_response :success
  end

  test "kitchen manager can access new" do
    get new_plat_url
    assert_response :success
  end

  test "kitchen manager can access edit" do
    get edit_plat_url(@plat)
    assert_response :success
  end

  test "admin can access everything" do
    sign_in @admin
    get plats_url
    assert_response :success

    get new_plat_url
    assert_response :success

    get edit_plat_url(@plat)
    assert_response :success
  end

  test "create stores a plat" do
    assert_difference "Plat.count", 1 do
      post plats_url, params: {
        plat: {
          name: "Escalivada",
          description: "Verdures rostides",
          tipusPlat: "entrant"
        }
      }
    end

    assert_redirected_to plat_url(Plat.last)
    assert_equal I18n.t("plats.messages.created_success"), flash[:notice]
  end

  test "create with ingredients stores plat with associations" do
    ingredient = ingredients(:milk)

    assert_difference "Plat.count", 1 do
      post plats_url, params: {
        plat: {
          name: "Salad",
          description: "Fresh salad",
          tipusPlat: "entrant",
          ingredient_ids: [ ingredient.id ]
        }
      }
    end

    plat = Plat.last
    assert_equal 1, plat.ingredients.count
    assert_includes plat.ingredients, ingredient
  end

  test "create with invalid params re-renders form" do
    assert_no_difference "Plat.count" do
      post plats_url, params: {
        plat: {
          name: "",
          description: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "update changes plat name" do
    patch plat_url(@plat), params: {
      plat: {
        name: "Paella Valenciana"
      }
    }

    assert_redirected_to plat_url(@plat)
    assert_equal I18n.t("plats.messages.updated_success"), flash[:notice]
    assert_equal "Paella Valenciana", @plat.reload.name
  end

  test "update changes plat tipus" do
    patch plat_url(@plat), params: {
      plat: {
        name: @plat.name,
        tipusPlat: "segon"
      }
    }

    assert_redirected_to plat_url(@plat)
    assert_equal "segon", @plat.reload.tipusPlat
  end

  test "update changes plat description" do
    new_description = "Arroz con verduras y mariscos"

    patch plat_url(@plat), params: {
      plat: {
        name: @plat.name,
        description: new_description
      }
    }

    assert_redirected_to plat_url(@plat)
    assert_equal new_description, @plat.reload.description
  end

  test "update changes plat ingredients" do
    ingredient = ingredients(:milk)

    assert_no_difference "PlatIngredient.count" do
      patch plat_url(@plat), params: {
        plat: {
          name: @plat.name,
          ingredient_ids: [ ingredient.id ]
        }
      }
    end

    assert_includes @plat.reload.ingredients, ingredient
  end

  test "update with invalid params re-renders form" do
    original_name = @plat.name

    patch plat_url(@plat), params: {
      plat: {
        name: ""
      }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @plat.reload.name
  end

  test "destroy removes a plat" do
    plat = plats(:olivas)

    assert_difference "Plat.count", -1 do
      delete plat_url(plat)
    end

    assert_redirected_to plats_url
    assert_equal I18n.t("plats.messages.destroyed_success"), flash[:notice]
  end

  test "waiter cannot create plats" do
    sign_in @waiter

    assert_no_difference "Plat.count" do
      post plats_url, params: {
        plat: {
          name: "Test Plat",
          description: "Test"
        }
      }
    end

    assert_redirected_to root_url
  end

  test "waiter cannot update plats" do
    sign_in @waiter

    assert_no_changes -> { @plat.reload.name } do
      patch plat_url(@plat), params: {
        plat: {
          name: "Updated Name"
        }
      }
    end

    assert_redirected_to root_url
  end

  test "waiter cannot destroy plats" do
    sign_in @waiter

    assert_no_difference "Plat.count" do
      delete plat_url(@plat)
    end

    assert_redirected_to root_url
  end

  test "update requires authentication" do
    sign_out @kitchen_manager

    patch plat_url(@plat), params: {
      plat: {
        name: "Updated"
      }
    }

    assert_redirected_to new_user_session_url
  end

  test "destroy requires authentication" do
    sign_out @kitchen_manager

    delete plat_url(@plat)

    assert_redirected_to new_user_session_url
  end
end
