require "test_helper"

class PreparationsCreationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @dish = dishes(:paella)
    @preparation = preparations(:pasta_prep)
  end

  test "guest cannot access new preparation page or post" do
    get new_preparation_path
    assert_redirected_to new_user_session_path

    post preparations_path, params: { preparation: { name: "Guest Prep", time_minutes: 10, difficulty: "easy" } }
    assert_redirected_to new_user_session_path
  end

  test "waiter cannot access new preparation page or post" do
    sign_in @waiter

    get new_preparation_path
    assert_redirected_to root_path

    post preparations_path, params: { preparation: { name: "Waiter Prep", time_minutes: 10, difficulty: "easy" } }
    assert_redirected_to root_path
  end

  test "kitchen manager can see and submit new preparation form with valid params" do
    sign_in @kitchen_manager

    # Go to index page and verify "Nova preparació" link exists
    get preparations_path
    assert_response :success
    assert_select "a[href='#{new_preparation_path}']", text: /#{Regexp.escape(I18n.t("preparations.index.new_preparation"))}/

    # Go to new preparation form
    get new_preparation_path
    assert_response :success

    # Assert form exists and has right inputs
    assert_select "form[action='#{preparations_path}']" do
      assert_select "input[name='preparation[name]']"
      assert_select "textarea[name='preparation[description]']"
      assert_select "input[name='preparation[time_minutes]']"
      assert_select "select[name='preparation[difficulty]']"
      assert_select "select[name='preparation[dish_id]']"
    end

    # Submit valid form
    assert_difference "Preparation.count", 1 do
      post preparations_path, params: {
        preparation: {
          name: "Fresh Rice Prep",
          description: "Cook the rice with standard settings.",
          time_minutes: 18,
          difficulty: "easy",
          dish_id: @dish.id
        }
      }
    end

    new_prep = Preparation.last
    assert_redirected_to preparation_path(new_prep)
    follow_redirect!
    assert_response :success

    # Verify notice is shown and content is rendered
    assert_equal I18n.t("preparations.messages.created_success"), flash[:notice]
    assert_select ".notice-info .notice-title", text: /#{Regexp.escape(I18n.t("preparations.messages.created_success"))}/
    assert_match "Fresh Rice Prep", response.body
    assert_match "Cook the rice with standard settings.", response.body
    assert_match "18 min", response.body
    assert_match @dish.name, response.body
  end

  test "kitchen manager sees errors when submitting invalid preparation form" do
    sign_in @kitchen_manager

    get new_preparation_path
    assert_response :success

    # Submit invalid details
    assert_no_difference "Preparation.count" do
      post preparations_path, params: {
        preparation: {
          name: "",
          description: "No name.",
          time_minutes: 0,
          difficulty: "hard"
        }
      }
    end

    assert_response :unprocessable_entity
    # Errors are shown in .alert-error block
    assert_select ".alert-error"
    # Form elements are re-rendered
    assert_select "form[action='#{preparations_path}']"
    # Description should be preserved
    assert_select "textarea[name='preparation[description]']", text: "No name."
  end

  test "waiter does not see new preparation button in index" do
    sign_in @waiter
    get preparations_path
    assert_response :success
    assert_select "a[href='#{new_preparation_path}']", count: 0
  end

  test "preparations index supports search query parameter" do
    sign_in @kitchen_manager

    # When no search parameter is given, we should see both fixtures
    get preparations_path
    assert_response :success
    assert_select ".strong", text: "Pasta Preparation"
    assert_select ".strong", text: "Rice Preparation"

    # When search parameter "Pasta" is given, we should only see Pasta Preparation
    get preparations_path, params: { search: "Pasta" }
    assert_response :success
    assert_select ".strong", text: "Pasta Preparation"
    assert_select ".strong", text: "Rice Preparation", count: 0
  end

  test "preparations index supports grid view toggle" do
    sign_in @kitchen_manager

    # Default is list view (rendered inside a card element)
    get preparations_path
    assert_response :success
    assert_select ".card"
    assert_select ".grid.grid-3", count: 0

    # With view parameter set to grid
    get preparations_path, params: { view: "grid" }
    assert_response :success
    assert_select ".grid.grid-3"
    assert_select ".dish-title", text: "Pasta Preparation"
    # Tag for difficulty
    assert_select ".tag-preference", text: I18n.t("preparations.difficulties.easy")
  end

  test "preparations index supports filtering by difficulty" do
    sign_in @kitchen_manager

    # Go to preparations index page and filter by "medium"
    get preparations_path, params: { difficulty: "medium" }
    assert_response :success

    # We should see Rice Preparation (medium) but not Pasta Preparation (easy)
    assert_select ".strong", text: "Rice Preparation"
    assert_select ".strong", text: "Pasta Preparation", count: 0

    # Ensure difficulty filter chip is selected/active (aria-pressed="true")
    assert_select "a.chip[aria-pressed='true']", text: I18n.t("preparations.difficulties.medium")
    assert_select "a.chip[aria-pressed='false']", text: I18n.t("preparations.difficulties.easy")

    # Clear button should be visible
    assert_select "a.chip-clear", text: I18n.t("filters.clear")
  end

  test "kitchen manager can update preparation with valid params" do
    sign_in @kitchen_manager

    # Go to show page first to verify edit link exists
    get preparation_path(@preparation)
    assert_response :success
    assert_select "a[href='#{edit_preparation_path(@preparation)}']"

    # Go to edit page
    get edit_preparation_path(@preparation)
    assert_response :success
    assert_select "form[action='#{preparation_path(@preparation)}']"

    # Update preparation
    patch preparation_path(@preparation), params: {
      preparation: {
        name: "Renamed Pasta Prep",
        description: "Cook for 12 minutes now.",
        time_minutes: 12,
        difficulty: "easy"
      }
    }

    assert_redirected_to preparation_path(@preparation)
    follow_redirect!
    assert_response :success

    # Verify notice and changes are shown
    assert_equal I18n.t("preparations.messages.updated_success"), flash[:notice]
    assert_select ".notice-info .notice-title", text: /#{Regexp.escape(I18n.t("preparations.messages.updated_success"))}/
    assert_match "Renamed Pasta Prep", response.body
    assert_match "Cook for 12 minutes now.", response.body
    assert_match "12 min", response.body
  end

  test "kitchen manager sees errors when updating with invalid params" do
    sign_in @kitchen_manager

    get edit_preparation_path(@preparation)
    assert_response :success

    # Submit invalid changes
    patch preparation_path(@preparation), params: {
      preparation: {
        name: "",
        time_minutes: -1
      }
    }

    assert_response :unprocessable_entity
    assert_select ".alert-error"
    assert_select "form[action='#{preparation_path(@preparation)}']"
  end

  test "waiter does not see edit link on show page and cannot update" do
    sign_in @waiter

    get preparation_path(@preparation)
    assert_response :success
    assert_select "a[href='#{edit_preparation_path(@preparation)}']", count: 0

    patch preparation_path(@preparation), params: {
      preparation: {
        name: "Waiter Rename"
      }
    }
    assert_redirected_to root_path
  end
end
