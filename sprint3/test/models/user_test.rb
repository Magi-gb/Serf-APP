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

  test "invalid when password confirmation does not match on create" do
    user = User.new(username: "testuser", password: "password", password_confirmation: "different", role: :waiter)
    assert_not user.valid?
    assert user.errors.added?(:password_confirmation, :confirmation, attribute: "Contrasenya")
  end

  test "invalid when password confirmation does not match on update" do
    user = users(:waiter)
    user.password = "newpassword"
    user.password_confirmation = "mismatch"
    assert_not user.valid?
    assert user.errors.added?(:password_confirmation, :confirmation, attribute: "Contrasenya")
  end

  test "persisted user validates password if provided" do
    user = users(:waiter)
    user.password = "short"
    assert_not user.valid?
    assert user.errors.added?(:password, :too_short, count: 6)
  end

  test "search scope returns matching users" do
    results = User.search("admin")
    assert_includes results, users(:admin)
    assert_not_includes results, users(:waiter)
  end

  test "search scope returns all users when query is blank" do
    assert_equal User.all.to_a, User.search("").to_a
    assert_equal User.all.to_a, User.search(nil).to_a
  end

  test "search scope is case-insensitive" do
    results = User.search("ADMIN")
    assert_includes results, users(:admin)
  end
end
