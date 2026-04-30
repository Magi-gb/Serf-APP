require "test_helper"

class ProtocolsAccessTest < ActionDispatch::IntegrationTest
  def setup
    @protocol = protocols(:allergy)
    @kitchen_manager = users(:kitchen_manager)
    @admin = users(:admin)
    @waiter = users(:waiter)
  end

  test "kitchen_manager sees only read-only protocols list" do
    sign_in @kitchen_manager
    get protocols_path
    assert_response :success
    assert_select "table.serf-table"
    assert_select "a", text: "+ Nou protocol", count: 0
    assert_select "a", text: "Editar", count: 0
    assert_select "a", text: "Eliminar", count: 0
  end

  test "waiter does not see protocols link in sidebar" do
    sign_in @waiter
    get root_path
    assert_select "a", text: "Protocols", count: 0
  end
end
