require "test_helper"

class PreparationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @kitchen_manager = users(:kitchen_manager)
    @waiter = users(:waiter)
    @admin = users(:admin)
    @dish = dishes(:paella)
    @preparation = preparations(:pasta_prep)

    sign_in @kitchen_manager
  end

  test "index requires authentication" do
    sign_out @kitchen_manager
    get preparations_url
    assert_redirected_to new_user_session_url
  end

  test "waiter cannot access index" do
    sign_in @waiter
    get preparations_url
    assert_redirected_to root_url
  end

  test "waiter cannot access show" do
    sign_in @waiter
    get preparation_url(@preparation)
    assert_redirected_to root_url
  end

  test "waiter cannot access new" do
    sign_in @waiter
    get new_preparation_url
    assert_redirected_to root_url
  end

  test "kitchen manager can access index" do
    get preparations_url
    assert_response :success
  end

  test "kitchen manager can access show" do
    get preparation_url(@preparation)
    assert_response :success
  end

  test "kitchen manager can access new" do
    get new_preparation_url
    assert_response :success
  end

  test "admin can access everything" do
    sign_in @admin
    get preparations_url
    assert_response :success

    get preparation_url(@preparation)
    assert_response :success

    get new_preparation_url
    assert_response :success
  end

  test "create stores a preparation" do
    assert_difference "Preparation.count", 1 do
      post preparations_url, params: {
        preparation: {
          name: "New Unique Preparation",
          description: "New description",
          time_minutes: 25,
          difficulty: "medium",
          dish_id: @dish.id
        }
      }
    end

    assert_redirected_to preparation_url(Preparation.last)
    assert_equal I18n.t("preparations.messages.created_success"), flash[:notice]
  end

  test "create with invalid params re-renders form" do
    assert_no_difference "Preparation.count" do
      post preparations_url, params: {
        preparation: {
          name: "",
          time_minutes: -5,
          difficulty: "easy"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "waiter cannot create preparations" do
    sign_in @waiter

    assert_no_difference "Preparation.count" do
      post preparations_url, params: {
        preparation: {
          name: "Invalid Waiter Prep",
          time_minutes: 10,
          difficulty: "easy"
        }
      }
    end

    assert_redirected_to root_url
  end
end
