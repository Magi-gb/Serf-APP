require "test_helper"

class PruebaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get prueba_index_url
    assert_response :success
  end
end
