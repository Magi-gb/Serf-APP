require "test_helper"

class DishElaborationTest < ActiveSupport::TestCase
  test "is valid with dish and elaboration" do
    de = DishElaboration.new(
      dish: dishes(:paella),
      elaboration: elaborations(:beixamel)
    )
    assert de.valid?
  end

  test "belongs to dish" do
    de = dish_elaborations(:lasanya_bolognesa)
    assert_equal dishes(:lasanya), de.dish
  end

  test "belongs to elaboration" do
    de = dish_elaborations(:lasanya_bolognesa)
    assert_equal elaborations(:bolognesa), de.elaboration
  end
end
