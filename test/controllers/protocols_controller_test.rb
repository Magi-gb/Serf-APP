require "test_helper"

class ProtocolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @protocol = protocols(:allergy)
    @admin = users(:admin)
    @waiter = users(:waiter)
  end

  test "should redirect index when not logged in" do
    get protocols_url
    assert_redirected_to new_user_session_url
  end

  test "waiter should get index" do
    sign_in @waiter
    get protocols_url
    assert_response :success
  end

  test "waiter should get show" do
    sign_in @waiter
    get protocol_url(@protocol)
    assert_response :success
  end

  test "waiter should NOT get new" do
    sign_in @waiter
    get new_protocol_url
    assert_redirected_to root_url
  end

  test "waiter should NOT create protocol" do
    sign_in @waiter
    assert_no_difference("Protocol.count") do
      post protocols_url, params: { protocol: { name: "New Protocol", description: "Test" } }
    end
    assert_redirected_to root_url
  end

  test "waiter should NOT get edit" do
    sign_in @waiter
    get edit_protocol_url(@protocol)
    assert_redirected_to root_url
  end

  test "waiter should NOT update protocol" do
    sign_in @waiter
    patch protocol_url(@protocol), params: { protocol: { name: "Updated Name" } }
    assert_redirected_to root_url
  end

  test "waiter should NOT destroy protocol" do
    sign_in @waiter
    assert_no_difference("Protocol.count") do
      delete protocol_url(@protocol)
    end
    assert_redirected_to root_url
  end

  test "admin should get new" do
    sign_in @admin
    get new_protocol_url
    assert_response :success
  end

  test "admin should create protocol" do
    sign_in @admin
    assert_difference("Protocol.count") do
      post protocols_url, params: { protocol: { name: "New Test Protocol", description: "A new protocol" } }
    end
    assert_redirected_to protocol_url(Protocol.last)
  end

  test "admin should get edit" do
    sign_in @admin
    get edit_protocol_url(@protocol)
    assert_response :success
  end

  test "admin should update protocol" do
    sign_in @admin
    patch protocol_url(@protocol), params: { protocol: { name: "Updated Name" } }
    assert_redirected_to protocol_url(@protocol)
    @protocol.reload
    assert_equal "Updated Name", @protocol.name
  end

  test "admin should destroy protocol" do
    sign_in @admin
    protocol_to_delete = protocols(:cross_contamination)
    assert_difference("Protocol.count", -1) do
      delete protocol_url(protocol_to_delete)
    end
    assert_redirected_to protocols_url
  end

  test "create protocol with invalid name should fail" do
    sign_in @admin
    assert_no_difference("Protocol.count") do
      post protocols_url, params: { protocol: { name: "", description: "Test" } }
    end
    assert_response :unprocessable_entity
  end

  test "create protocol with duplicate name should fail" do
    sign_in @admin
    assert_no_difference("Protocol.count") do
      post protocols_url, params: { protocol: { name: @protocol.name, description: "Test" } }
    end
    assert_response :unprocessable_entity
  end
end
