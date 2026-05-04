require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "creates a menu with valid name" do
    menu = Menu.new(name: "Menú del día")

    assert menu.valid?
  end

  test "validates presence of name" do
    menu = Menu.new

    assert_not menu.valid?
    assert menu.errors[:name].any?
  end

  test "validates uniqueness of name" do
    Menu.create!(name: "Menú especial")

    duplicate = Menu.new(name: "Menú especial")

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "defines future dish types scaffold for parallel integration" do
    assert_equal %w[starter main dessert], Menu::DISH_TYPES
  end
end
