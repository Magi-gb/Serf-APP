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

  test "index renders catalog table with legend columns" do
    get restrictions_url
    assert_select "div.rx-legend"
    assert_select "a.rx-row"
  end

  test "index search filters by name" do
    get restrictions_url, params: { q: "Gluten" }
    assert_response :success
    assert_select "a.rx-row", minimum: 1
  end

  test "index list view shows type filter chips" do
    get restrictions_url, params: { view: "list" }
    assert_response :success
    assert_select "a.chip"
  end

  test "index grouped view shows section headers" do
    get restrictions_url, params: { view: "grouped" }
    assert_response :success
    assert_select "div.rx-section-header"
  end

  test "should get new" do
    get new_restriction_url
    assert_response :success
  end

  test "should create restriction" do
    assert_difference("Restriction.count") do
      post restrictions_url, params: { restriction: { name: "Ou", description: "Conté ou", restriction_type: :intolerance_allergy, severity: :high } }
    end

    assert_redirected_to restriction_url(Restriction.last)
    assert_equal "high", Restriction.last.severity
  end

  test "show renders severity tag" do
    get restriction_url(@restriction)
    assert_response :success
    assert_select "span.tag-severity-high"
  end

  test "show renders metadata section" do
    get restriction_url(@restriction)
    assert_response :success
    assert_select "aside.show-side"
  end

  test "show renders not_dispensable tag for dish with essential ingredient" do
    get restriction_url(@restriction)
    assert_response :success
    assert_select "span.tag-allergen", text: /No dispensable/
  end

  test "show renders dispensable tag for dish with non-essential ingredient" do
    get restriction_url(restrictions(:lactose))
    assert_response :success
    assert_select "span.tag-preference", text: /Dispensable/
  end

  test "show renders affected dishes section" do
    get restriction_url(@restriction)
    assert_response :success
    assert_select "a[href=?]", dish_path(dishes(:olivas))
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
