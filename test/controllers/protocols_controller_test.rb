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

  test "should redirect show when not logged in" do
    get protocol_url(@protocol)
    assert_redirected_to new_user_session_url
  end

  test "waiter should get index" do
    sign_in @waiter
    get protocols_url
    assert_response :success
    assert_select "a[href='#{protocol_path(@protocol)}']"
    assert_select "a[href='#{protocols_path}']", text: I18n.t("sidebar.protocols")
  end

  test "waiter should get show" do
    sign_in @waiter
    get protocol_url(@protocol)
    assert_response :success
    assert_select ".serf-page-title", text: @protocol.name
  end

  test "waiter should see empty state when there are no protocols" do
    Protocol.delete_all
    sign_in @waiter

    get protocols_url

    assert_response :success
    assert_select ".empty-state", text: I18n.t("protocols.index.empty")
    assert_select ".list-card", count: 0
  end

  test "waiter should NOT get edit" do
    sign_in @waiter
    get edit_protocol_url(@protocol)
    assert_redirected_to root_url
  end

  test "waiter should NOT update protocol" do
    sign_in @waiter
    assert_no_changes -> { @protocol.reload.name } do
      patch protocol_url(@protocol), params: { protocol: { name: "Updated Name" } }
    end
    assert_redirected_to root_url
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

  test "update protocol with invalid name should fail" do
    sign_in @admin
    assert_no_changes -> { @protocol.reload.name } do
      patch protocol_url(@protocol), params: { protocol: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "update protocol with duplicate name should fail" do
    sign_in @admin
    duplicated_protocol = protocols(:cross_contamination)

    assert_no_changes -> { @protocol.reload.name } do
      patch protocol_url(@protocol), params: { protocol: { name: duplicated_protocol.name } }
    end
    assert_response :unprocessable_entity
  end

  test "waiter should NOT get new" do
    sign_in @waiter
    get new_protocol_url
    assert_redirected_to root_url
  end

  test "waiter should NOT create protocol" do
    sign_in @waiter
    assert_no_changes -> { Protocol.count } do
      post protocols_url, params: { protocol: { name: "New Protocol", description: "Test" } }
    end
    assert_redirected_to root_url
  end

  test "admin should get new" do
    sign_in @admin
    get new_protocol_url
    assert_response :success
    assert_select ".serf-page-title", text: I18n.t("protocols.new.title")
  end

  test "admin should create protocol with valid params" do
    sign_in @admin
    assert_changes -> { Protocol.count }, from: 2, to: 3 do
      post protocols_url, params: { protocol: { name: "New Protocol", description: "Test Description" } }
    end
    assert_redirected_to protocols_url
    assert_equal I18n.t("protocols.messages.created_success"), flash[:notice]
  end

  test "admin should NOT create protocol with blank name" do
    sign_in @admin
    assert_no_changes -> { Protocol.count } do
      post protocols_url, params: { protocol: { name: "", description: "Test" } }
    end
    assert_response :unprocessable_entity
    assert_select ".alert-error"
  end

  test "admin should NOT create protocol with duplicate name" do
    sign_in @admin
    assert_no_changes -> { Protocol.count } do
      post protocols_url, params: { protocol: { name: @protocol.name, description: "Test" } }
    end
    assert_response :unprocessable_entity
    assert_select ".alert-error"
  end

  test "admin can create protocol with optional description" do
    sign_in @admin
    assert_changes -> { Protocol.count }, from: 2, to: 3 do
      post protocols_url, params: { protocol: { name: "Protocol Without Description" } }
    end
    assert_redirected_to protocols_url
  end

  test "waiter should NOT destroy protocol" do
    sign_in @waiter
    assert_no_changes -> { Protocol.count } do
      delete protocol_url(@protocol)
    end
    assert_redirected_to root_url
  end

  test "admin should destroy protocol" do
    sign_in @admin
    assert_changes -> { Protocol.count }, -1 do
      delete protocol_url(@protocol)
    end
    assert_redirected_to protocols_url
    assert_equal I18n.t("protocols.messages.destroyed_success"), flash[:notice]
  end
end
