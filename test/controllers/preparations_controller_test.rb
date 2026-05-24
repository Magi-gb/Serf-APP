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

  test "waiter can access index" do
    sign_in @waiter
    get preparations_url
    assert_response :success
  end

  test "waiter can access show" do
    sign_in @waiter
    get preparation_url(@preparation)
    assert_response :success
  end

  test "waiter cannot access new" do
    sign_in @waiter
    get new_preparation_url
    assert_redirected_to root_url
  end

  test "index search filters preparations by name" do
    get preparations_url, params: { search: "Pasta" }
    assert_response :success
    assert_select ".strong", text: "Pasta Preparation"
    assert_select ".strong", text: "Rice Preparation", count: 0
  end

  test "index search filters preparations by description" do
    get preparations_url, params: { search: "steam" }
    assert_response :success
    assert_select ".strong", text: "Rice Preparation"
    assert_select ".strong", text: "Pasta Preparation", count: 0
  end

  test "index filters preparations by difficulty" do
    get preparations_url, params: { difficulty: "easy" }
    assert_response :success
    assert_select ".strong", text: "Pasta Preparation"
    assert_select ".strong", text: "Rice Preparation", count: 0
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

  test "kitchen manager can access edit" do
    get edit_preparation_url(@preparation)
    assert_response :success
  end

  test "waiter cannot access edit" do
    sign_in @waiter
    get edit_preparation_url(@preparation)
    assert_redirected_to root_url
  end

  test "update stores changes" do
    patch preparation_url(@preparation), params: {
      preparation: {
        name: "Updated Name",
        description: "Updated description",
        time_minutes: 30,
        difficulty: "hard"
      }
    }

    assert_redirected_to preparation_url(@preparation)
    assert_equal I18n.t("preparations.messages.updated_success"), flash[:notice]
    @preparation.reload
    assert_equal "Updated Name", @preparation.name
    assert_equal "Updated description", @preparation.description
    assert_equal 30, @preparation.time_minutes
    assert_equal "hard", @preparation.difficulty
  end

  test "update with invalid params re-renders edit form" do
    patch preparation_url(@preparation), params: {
      preparation: {
        name: "",
        time_minutes: -10
      }
    }

    assert_response :unprocessable_entity
    @preparation.reload
    assert_not_equal "", @preparation.name
  end

  test "waiter cannot update preparations" do
    sign_in @waiter

    patch preparation_url(@preparation), params: {
      preparation: {
        name: "Waiter Attempted Update"
      }
    }

    assert_redirected_to root_url
    @preparation.reload
    assert_not_equal "Waiter Attempted Update", @preparation.name
  end
end
