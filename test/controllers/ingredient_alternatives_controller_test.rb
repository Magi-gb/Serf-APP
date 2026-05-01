require "test_helper"

class IngredientAlternativesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ingredient = ingredients(:bread)
    @alternative = ingredients(:milk)
    @kitchen_manager = users(:kitchen_manager)
  end

  test "create requires authentication" do
    post ingredient_alternatives_path(@ingredient), params: {
      ingredient_alternative: { alternative_id: @alternative.id }
    }

    assert_redirected_to new_user_session_url
  end

  test "authenticated user can create ingredient alternative" do
    sign_in @kitchen_manager

    assert_difference("IngredientAlternative.count", 1) do
      post ingredient_alternatives_path(@ingredient), params: {
        ingredient_alternative: { alternative_id: @alternative.id }
      }
    end

    assert_redirected_to ingredient_path(@ingredient)
  end

  test "authenticated user can destroy ingredient alternative" do
    sign_in @kitchen_manager

    IngredientAlternative.create!(ingredient: @ingredient, alternative: @alternative)

    assert_difference("IngredientAlternative.count", -1) do
      delete ingredient_alternative_path(@ingredient, @alternative)
    end

    assert_redirected_to ingredient_path(@ingredient)
  end
end
