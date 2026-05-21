require "test_helper"

class PreparationsCreationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @dish = dishes(:paella)
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
    # waiter gets redirected to root when requesting preparations_path
    get preparations_path
    assert_redirected_to root_path
  end
end
