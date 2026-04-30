require "test_helper"

class ProtocolUpdateTest < ActionDispatch::IntegrationTest
  setup do
    @protocol = protocols(:allergy)
    @admin = users(:admin)
    @waiter = users(:waiter)
  end

  test "admin can edit protocol" do
    sign_in @admin

    get edit_protocol_url(@protocol)

    assert_response :success
  end

  test "admin can update protocol" do
    sign_in @admin

    patch protocol_url(@protocol), params: {
      protocol: {
        name: "Protocol actualitzat",
        description: "Descripcio actualitzada"
      }
    }

    assert_redirected_to protocol_url(@protocol)
    @protocol.reload
    assert_equal "Protocol actualitzat", @protocol.name
    assert_equal "Descripcio actualitzada", @protocol.description
  end

  test "admin sees edit form again when update is invalid" do
    sign_in @admin

    assert_no_changes -> { @protocol.reload.name } do
      patch protocol_url(@protocol), params: { protocol: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "waiter cannot edit protocol" do
    sign_in @waiter

    get edit_protocol_url(@protocol)

    assert_redirected_to root_url
  end

  test "waiter cannot update protocol" do
    sign_in @waiter

    assert_no_changes -> { @protocol.reload.name } do
      patch protocol_url(@protocol), params: { protocol: { name: "Intent cambrer" } }
    end

    assert_redirected_to root_url
  end
end
