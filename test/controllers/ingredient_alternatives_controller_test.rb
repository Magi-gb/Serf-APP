require "test_helper"

class IngredientAlternativesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ingredient = ingredients(:bread)
    @alternative = ingredients(:milk)
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
  end

  test "create requires authentication" do
    post ingredient_alternatives_path(@ingredient), params: {
      ingredient_alternative: { alternative_id: @alternative.id }
    }

    assert_redirected_to new_user_session_url
  end

  test "kitchen_manager can create ingredient alternative" do
    sign_in @kitchen_manager

    assert_difference("IngredientAlternative.count", 1) do
      post ingredient_alternatives_path(@ingredient), params: {
        ingredient_alternative: { alternative_id: @alternative.id }
      }
    end

    assert_redirected_to ingredient_path(@ingredient)
  end

  test "waiter cannot create ingredient alternative" do
    sign_in @waiter

    assert_no_difference("IngredientAlternative.count") do
      post ingredient_alternatives_path(@ingredient), params: {
        ingredient_alternative: { alternative_id: @alternative.id }
      }
    end

    assert_redirected_to root_url
  end

  test "kitchen_manager can destroy ingredient alternative" do
    sign_in @kitchen_manager

    IngredientAlternative.create!(ingredient: @ingredient, alternative: @alternative)

    assert_difference("IngredientAlternative.count", -1) do
      delete ingredient_alternative_path(@ingredient, @alternative)
    end

    assert_redirected_to ingredient_path(@ingredient)
  end

  test "waiter cannot destroy ingredient alternative" do
    IngredientAlternative.create!(ingredient: @ingredient, alternative: @alternative)

    sign_in @waiter

    assert_no_difference("IngredientAlternative.count") do
      delete ingredient_alternative_path(@ingredient, @alternative)
    end

    assert_redirected_to root_url
  end

  test "create rejects an alternative that introduces new restrictions" do
    sign_in @kitchen_manager
    kosher = restrictions(:kosher)
    pork = Ingredient.create!(name: "Pork #{Time.current.to_i}")
    IngredientRestriction.create!(ingredient: pork, restriction: kosher)

    assert_no_difference("IngredientAlternative.count") do
      post ingredient_alternatives_path(@ingredient), params: {
        ingredient_alternative: { alternative_id: pork.id }
      }
    end

    assert_redirected_to ingredient_path(@ingredient)
    follow_redirect!
    assert_match(/no pot afegir noves restriccions/, response.body)
  end

  test "create rejects self-reference" do
    sign_in @kitchen_manager

    assert_no_difference("IngredientAlternative.count") do
      post ingredient_alternatives_path(@ingredient), params: {
        ingredient_alternative: { alternative_id: @ingredient.id }
      }
    end

    assert_redirected_to ingredient_path(@ingredient)
  end

  test "update_collection adds and removes alternatives in one call" do
    sign_in @kitchen_manager
    second = Ingredient.create!(name: "Soy #{Time.current.to_i}")
    IngredientAlternative.create!(ingredient: @ingredient, alternative: @alternative)

    patch alternatives_ingredient_path(@ingredient), params: {
      alternative_ids: [ second.id.to_s ]
    }

    assert_redirected_to ingredient_path(@ingredient)
    @ingredient.reload
    assert_equal [ second.id ], @ingredient.alternative_ids
  end

  test "update_collection accepts an empty list and clears all alternatives" do
    sign_in @kitchen_manager
    IngredientAlternative.create!(ingredient: @ingredient, alternative: @alternative)

    patch alternatives_ingredient_path(@ingredient), params: { alternative_ids: [] }

    assert_redirected_to ingredient_path(@ingredient)
    assert_empty @ingredient.reload.alternative_ids
  end

  test "update_collection rolls back if any addition fails validation" do
    sign_in @kitchen_manager
    kosher = restrictions(:kosher)
    pork = Ingredient.create!(name: "Pork #{Time.current.to_i}")
    IngredientRestriction.create!(ingredient: pork, restriction: kosher)

    assert_no_difference("IngredientAlternative.count") do
      patch alternatives_ingredient_path(@ingredient), params: {
        alternative_ids: [ @alternative.id.to_s, pork.id.to_s ]
      }
    end

    assert_redirected_to ingredient_path(@ingredient)
    assert_empty @ingredient.reload.alternative_ids
  end

  test "waiter cannot update_collection" do
    sign_in @waiter

    patch alternatives_ingredient_path(@ingredient), params: {
      alternative_ids: [ @alternative.id.to_s ]
    }

    assert_redirected_to root_url
    assert_empty @ingredient.reload.alternative_ids
  end
end
