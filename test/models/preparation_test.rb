require "test_helper"

class PreparationTest < ActiveSupport::TestCase
  test "is valid with name, time_minutes and difficulty" do
    preparation = Preparation.new(name: "Test Prep", time_minutes: 15, difficulty: :easy)
    assert preparation.valid?
  end

  test "validates presence of name" do
    preparation = Preparation.new(time_minutes: 15, difficulty: :easy)
    assert_not preparation.valid?
    assert preparation.errors[:name].any?
  end

  test "validates uniqueness of name" do
    Preparation.create!(name: "Unique Prep", time_minutes: 10, difficulty: :easy)
    duplicate = Preparation.new(name: "Unique Prep", time_minutes: 15, difficulty: :easy)
    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end

  test "validates numericality of time_minutes" do
    prep = Preparation.new(name: "Test Prep", time_minutes: 0, difficulty: :easy)
    assert_not prep.valid?
    assert prep.errors[:time_minutes].any?

    prep2 = Preparation.new(name: "Test Prep", time_minutes: -5, difficulty: :easy)
    assert_not prep2.valid?
    assert prep2.errors[:time_minutes].any?

    prep3 = Preparation.new(name: "Test Prep", time_minutes: 10.5, difficulty: :easy)
    # numericality with only_integer: true will fail with 10.5
    assert_not prep3.valid?
  end

  test "rejects invalid difficulty values" do
    assert_raises(ArgumentError) do
      Preparation.new(name: "Test Prep", time_minutes: 15, difficulty: :invalid_difficulty)
    end
  end

  test "strips whitespace from name before validation" do
    preparation = Preparation.new(name: "  Spaghetti preparation   ", time_minutes: 20, difficulty: :medium)
    preparation.valid?
    assert_equal "Spaghetti preparation", preparation.name
  end
end
