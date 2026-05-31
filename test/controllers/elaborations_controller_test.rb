require "test_helper"

class ElaborationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @admin = users(:admin)
    @elaboration = elaborations(:bolognesa)
    sign_in @kitchen_manager
  end

  test "index requires authentication" do
    sign_out @kitchen_manager
    get elaborations_url
    assert_redirected_to new_user_session_url
  end

  test "index is accessible to all roles" do
    get elaborations_url
    assert_response :success

    sign_in @waiter
    get elaborations_url
    assert_response :success
  end

  test "show is accessible to all roles" do
    get elaboration_url(@elaboration)
    assert_response :success

    sign_in @waiter
    get elaboration_url(@elaboration)
    assert_response :success
  end

  test "waiter cannot access new" do
    sign_in @waiter
    get new_elaboration_url
    assert_redirected_to root_url
  end

  test "waiter cannot access edit" do
    sign_in @waiter
    get edit_elaboration_url(@elaboration)
    assert_redirected_to root_url
  end

  test "kitchen manager can access new" do
    get new_elaboration_url
    assert_response :success
  end

  test "kitchen manager can access edit" do
    get edit_elaboration_url(@elaboration)
    assert_response :success
  end

  test "admin can access all actions" do
    sign_in @admin
    get elaborations_url
    assert_response :success

    get new_elaboration_url
    assert_response :success

    get edit_elaboration_url(@elaboration)
    assert_response :success
  end

  test "create stores an elaboration" do
    assert_difference "Elaboration.count", 1 do
      post elaborations_url, params: {
        elaboration: { name: "Romesco", description: "Salsa catalana de fruits secs" }
      }
    end

    assert_redirected_to elaboration_url(Elaboration.last)
    assert_equal I18n.t("elaborations.messages.created_success"), flash[:notice]
  end

  test "create with ingredients stores associations" do
    ingredient = ingredients(:milk)

    assert_difference "Elaboration.count", 1 do
      post elaborations_url, params: {
        elaboration: {
          name: "Crema de llet",
          ingredient_ids: [ ingredient.id ]
        }
      }
    end

    elaboration = Elaboration.last
    assert_includes elaboration.ingredients, ingredient
  end

  test "create with invalid params re-renders form" do
    assert_no_difference "Elaboration.count" do
      post elaborations_url, params: { elaboration: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "update changes elaboration name" do
    patch elaboration_url(@elaboration), params: {
      elaboration: { name: "Salsa Bolonyesa Classica" }
    }

    assert_redirected_to elaboration_url(@elaboration)
    assert_equal I18n.t("elaborations.messages.updated_success"), flash[:notice]
    assert_equal "Salsa Bolonyesa Classica", @elaboration.reload.name
  end

  test "update with invalid params re-renders form" do
    original_name = @elaboration.name

    patch elaboration_url(@elaboration), params: {
      elaboration: { name: "" }
    }

    assert_response :unprocessable_entity
    assert_equal original_name, @elaboration.reload.name
  end

  test "destroy removes an elaboration" do
    elaboration = elaborations(:beixamel)

    assert_difference "Elaboration.count", -1 do
      delete elaboration_url(elaboration)
    end

    assert_redirected_to elaborations_url
    assert_equal I18n.t("elaborations.messages.destroyed_success"), flash[:notice]
  end

  test "waiter cannot create elaborations" do
    sign_in @waiter

    assert_no_difference "Elaboration.count" do
      post elaborations_url, params: {
        elaboration: { name: "Nova elaboració" }
      }
    end

    assert_redirected_to root_url
  end

  test "waiter cannot update elaborations" do
    sign_in @waiter

    assert_no_changes -> { @elaboration.reload.name } do
      patch elaboration_url(@elaboration), params: {
        elaboration: { name: "Nom canviat" }
      }
    end

    assert_redirected_to root_url
  end

  test "waiter cannot destroy elaborations" do
    sign_in @waiter

    assert_no_difference "Elaboration.count" do
      delete elaboration_url(@elaboration)
    end

    assert_redirected_to root_url
  end

  test "update requires authentication" do
    sign_out @kitchen_manager

    patch elaboration_url(@elaboration), params: {
      elaboration: { name: "Updated" }
    }

    assert_redirected_to new_user_session_url
  end

  test "destroy requires authentication" do
    sign_out @kitchen_manager

    delete elaboration_url(@elaboration)

    assert_redirected_to new_user_session_url
  end

  test "index search filters by name" do
    get elaborations_url, params: { search: "bolony" }

    assert_response :success
    assert_includes response.body, elaborations(:bolognesa).name
    assert_not_includes response.body, elaborations(:beixamel).name
  end

  test "show renders linked dishes" do
    get elaboration_url(elaborations(:bolognesa))

    assert_response :success
    assert_includes response.body, dishes(:lasanya).name
  end

  test "show renders restriction overview linked to the restriction" do
    get elaboration_url(elaborations(:bolognesa)) # bolognesa -> bread -> gluten

    assert_response :success
    assert_select "a.tag[href=?]", restriction_path(restrictions(:gluten))
  end

  test "index with include_restrictions shows only matching elaborations" do
    get elaborations_url, params: { include_restrictions: [ restrictions(:gluten).id ] }

    assert_response :success
    assert_includes response.body, elaborations(:bolognesa).name   # bread → gluten
    assert_not_includes response.body, elaborations(:beixamel).name
  end

  test "index with exclude_restrictions hides matching elaborations" do
    get elaborations_url, params: { exclude_restrictions: [ restrictions(:gluten).id ] }

    assert_response :success
    assert_not_includes response.body, elaborations(:bolognesa).name
    assert_includes response.body, elaborations(:beixamel).name
  end
end
