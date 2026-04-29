require "test_helper"

class ProtocolTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    protocol = Protocol.new(name: "Test Protocol", description: "This is a test.")
    assert protocol.valid?
  end

  test "should require a name" do
    protocol = Protocol.new(description: "This is a test.")
    assert_not protocol.valid?
    assert_includes protocol.errors[:name], I18n.t("errors.messages.blank")
  end

  test "should require a unique name" do
    existing_protocol = protocols(:allergy)
    protocol = Protocol.new(name: existing_protocol.name)
    assert_not protocol.valid?
    assert_includes protocol.errors[:name], I18n.t("errors.messages.taken")
  end
end
