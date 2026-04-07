require "test_helper"

class RestrictionTest < ActiveSupport::TestCase
  test "creates a restriction with valid attributes" do
    restriction = Restriction.new(name: "Gluten Unique #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    assert restriction.valid?
  end

  test "validates presence of name" do
    restriction = Restriction.new(restriction_type: :intolerance_allergy)
    assert_not restriction.valid?
    assert restriction.errors[:name].any?
  end

  test "validates uniqueness of name" do
    Restriction.create!(name: "Gluten Unique Test #{Time.current.to_i}", restriction_type: :intolerance_allergy)
    restriction = Restriction.new(name: "Gluten Unique Test #{Time.current.to_i}", restriction_type: :religious)
    assert_not restriction.valid?
    assert restriction.errors[:name].any?
  end

  test "validates presence of restriction_type" do
    restriction = Restriction.new(name: "Test #{Time.current.to_i}")
    assert_not restriction.valid?
    assert restriction.errors[:restriction_type].any?
  end

  test "has_many ingredient_restrictions association" do
    assert Restriction.new.respond_to?(:ingredient_restrictions)
  end

  test "has_many ingredients association through ingredient_restrictions" do
    assert Restriction.new.respond_to?(:ingredients)
  end
end
