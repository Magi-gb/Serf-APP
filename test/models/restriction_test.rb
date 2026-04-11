require "test_helper"

class RestrictionTest < ActiveSupport::TestCase
  test "destroying restriction destroys associated ingredient_restrictions" do
    restriction = restrictions(:one)
    assert_difference("IngredientRestriction.count", -1) do
      restriction.destroy
    end
  end
end
