require "test_helper"

class PlatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get plats_index_url
    assert_response :success
  end

  test "should get show" do
    get plats_show_url
    assert_response :success
  end

  test "should get new" do
    get plats_new_url
    assert_response :success
  end

  test "should get edit" do
    get plats_edit_url
    assert_response :success
  end
end
