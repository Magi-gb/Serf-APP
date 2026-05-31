require "test_helper"

class RestrictionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restriction = restrictions(:gluten)
    sign_in users(:admin)
  end

  test "should get index" do
    get restrictions_url
    assert_response :success
  end

  test "should get new" do
    get new_restriction_url
    assert_response :success
  end

  test "should create restriction" do
    assert_difference("Restriction.count") do
      post restrictions_url, params: { restriction: { name: "Ou", description: "Conté ou", restriction_type: :intolerance_allergy } }
    end

    assert_redirected_to restriction_url(Restriction.last)
  end

  test "should show restriction" do
    get restriction_url(@restriction)
    assert_response :success
  end

  test "show renders ingredients linked to the restriction" do
    get restriction_url(@restriction)
    assert_response :success
    assert_select "a[href=?]", ingredient_path(ingredients(:bread))
  end

  test "show renders no_ingredients message when restriction has no ingredients" do
    restriction = restrictions(:lactose)
    restriction.ingredient_restrictions.destroy_all
    get restriction_url(restriction)
    assert_response :success
    assert_select "div.muted", text: I18n.t("restrictions.show.no_ingredients")
  end

  test "should get edit" do
    get edit_restriction_url(@restriction)
    assert_response :success
  end

  test "should update restriction" do
    patch restriction_url(@restriction), params: { restriction: { description: @restriction.description, name: @restriction.name } }
    assert_redirected_to restriction_url(@restriction)
  end

  test "should destroy restriction" do
    assert_difference("Restriction.count", -1) do
      delete restriction_url(@restriction)
    end

    assert_redirected_to restrictions_url
  end
end
