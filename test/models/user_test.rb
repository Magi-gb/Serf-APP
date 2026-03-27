require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(username: "testuser", password: "password", role: :waiter)
    assert user.valid?
  end

  test "invalid without username" do
    user = User.new(password: "password", role: :waiter)
    assert_not user.valid?
    assert user.errors.added?(:username, :blank)
  end

  test "invalid without password on create" do
    user = User.new(username: "testuser", role: :waiter)
    assert_not user.valid?
    assert user.errors.added?(:password, :blank)
  end

  test "invalid with short password" do
    user = User.new(username: "testuser", password: "short", role: :waiter)
    assert_not user.valid?
    assert user.errors.added?(:password, :too_short, count: 6)
  end

  test "username must be unique" do
    User.create!(username: "duplicate", password: "password", role: :waiter)
    user = User.new(username: "duplicate", password: "password", role: :waiter)
    assert_not user.valid?
    assert user.errors.added?(:username, :taken, value: "duplicate")
  end

  test "default role is waiter" do
    user = User.new
    assert_equal "waiter", user.role
  end

  test "role enum values" do
    assert_equal 0, User.roles[:waiter]
    assert_equal 1, User.roles[:kitchen_manager]
    assert_equal 2, User.roles[:admin]
  end

  test "role query methods" do
    assert User.new(role: :waiter).waiter?
    assert User.new(role: :kitchen_manager).kitchen_manager?
    assert User.new(role: :admin).admin?
  end

  test "persisted user can update without password" do
    user = users(:waiter)
    user.username = "updated_waiter"
    assert user.valid?
  end

  test "persisted user validates password if provided" do
    user = users(:waiter)
    user.password = "short"
    assert_not user.valid?
    assert user.errors.added?(:password, :too_short, count: 6)
  end
end
