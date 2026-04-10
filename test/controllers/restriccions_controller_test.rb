require "test_helper"

class RestriccionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get restriccions_index_url
    assert_response :success
  end

  test "should get show" do
    get restriccions_show_url
    assert_response :success
  end

  test "should get new" do
    get restriccions_new_url
    assert_response :success
  end

  test "should get edit" do
    get restriccions_edit_url
    assert_response :success
  end
end
