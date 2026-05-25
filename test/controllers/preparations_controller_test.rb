require "test_helper"

class PreparationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @preparation = preparations(:a_la_planxa)
  end

  # --- index ---

  test "waiter can access index" do
    sign_in users(:waiter)
    get preparations_url
    assert_response :success
  end

  test "kitchen_manager can access index" do
    sign_in users(:kitchen_manager)
    get preparations_url
    assert_response :success
  end

  # --- show ---

  test "waiter can access show" do
    sign_in users(:waiter)
    get preparation_url(@preparation)
    assert_response :success
  end

  test "kitchen_manager can access show" do
    sign_in users(:kitchen_manager)
    get preparation_url(@preparation)
    assert_response :success
  end

  # --- destroy ---

  test "kitchen_manager can destroy preparation" do
    sign_in users(:kitchen_manager)
    assert_difference("Preparation.count", -1) do
      delete preparation_url(@preparation)
    end
    assert_redirected_to preparations_url
  end

  test "admin can destroy preparation" do
    sign_in users(:admin)
    assert_difference("Preparation.count", -1) do
      delete preparation_url(preparations(:bullida))
    end
    assert_redirected_to preparations_url
  end

  test "waiter cannot destroy preparation" do
    sign_in users(:waiter)
    assert_no_difference("Preparation.count") do
      delete preparation_url(@preparation)
    end
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot destroy preparation" do
    assert_no_difference("Preparation.count") do
      delete preparation_url(@preparation)
    end
    assert_redirected_to new_user_session_path
  end

  test "destroy nonexistent preparation returns 404" do
    sign_in users(:admin)
    delete preparation_url(id: 0)
    assert_response :not_found
  end
end
