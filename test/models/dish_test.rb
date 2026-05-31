require "test_helper"
require "minitest/mock"

class DishTest < ActiveSupport::TestCase
  test "is valid with name, description, dish_type and at least one ingredient" do
    dish = Dish.new(name: "Test Dish", description: "Test description", dish_type: :entrant)
    dish.ingredients << ingredients(:milk)
    assert dish.valid?
  end

  test "is invalid without ingredients" do
    dish = Dish.new(name: "Test Dish", description: "Test description", dish_type: :entrant)
    assert_not dish.valid?
    assert dish.errors[:ingredients].any?
  end

  test "validates presence of name" do
    dish = Dish.new(description: "Test", dish_type: :entrant)
    assert_not dish.valid?
    assert dish.errors[:name].any?
  end

  test "allows blank description" do
    dish = Dish.new(name: "Test", dish_type: :entrant)
    dish.valid?
    assert_empty dish.errors[:description]
  end

  test "rejects invalid dish_type values" do
    assert_raises(ArgumentError) do
      Dish.new(name: "Test", description: "Test", dish_type: :invalid_type)
    end
  end

  test "accepts all enum values for dish_type" do
    %i[entrant primer segon postre].each do |type|
      dish = Dish.new(name: "Dish #{type}", description: "d", dish_type: type)
      assert_equal type.to_s, dish.dish_type
    end
  end

  test "strips whitespace from name before validation" do
    dish = Dish.new(name: "  Paella  ", description: "Test", dish_type: :primer)
    dish.valid?
    assert_equal "Paella", dish.name
  end

  test "has many menus through menu_dishes" do
    dish = dishes(:paella)
    assert_respond_to dish, :menus
    assert dish.menus.include?(menus(:weekly_menu))
  end

  test "has many ingredients through dish_ingredients" do
    dish = dishes(:paella)
    assert_respond_to dish, :ingredients
    assert dish.ingredients.include?(ingredients(:milk))
  end

  test "destroys menu_dishes when dish is destroyed" do
    dish = dishes(:paella)
    menu_dishes_count = dish.menu_dishes.count
    md_count_before = MenuDish.count
    dish.destroy
    assert_equal md_count_before - menu_dishes_count, MenuDish.count
  end

  test "destroys dish_ingredients when dish is destroyed" do
    dish = dishes(:paella)
    di_count = dish.dish_ingredients.count
    di_count_before = DishIngredient.count
    dish.destroy
    assert_equal di_count_before - di_count, DishIngredient.count
  end

  # ---- image attachment ----

  test "is valid with an attached image of an accepted content type" do
    dish = Dish.new(name: "Test", description: "Test", dish_type: :entrant)
    dish.ingredients << ingredients(:milk)
    dish.image.attach(io: file_fixture("dish_sample.png").open, filename: "dish_sample.png", content_type: "image/png")
    assert dish.valid?, dish.errors.full_messages.to_sentence
  end

  test "is invalid with an attached file that is not an accepted image type" do
    dish = Dish.new(name: "Test", description: "Test", dish_type: :entrant)
    dish.ingredients << ingredients(:milk)
    dish.image.attach(io: file_fixture("not_an_image.txt").open, filename: "not_an_image.txt", content_type: "text/plain")
    assert_not dish.valid?
    assert dish.errors[:image].any?
  end

  test "is invalid when the attached image exceeds the maximum size" do
    dish = Dish.new(name: "Test", description: "Test", dish_type: :entrant)
    dish.ingredients << ingredients(:milk)
    dish.image.attach(io: file_fixture("dish_sample.png").open, filename: "dish_sample.png", content_type: "image/png")
    dish.image.blob.stub(:byte_size, Dish::MAX_IMAGE_SIZE + 1) do
      assert_not dish.valid?
      assert dish.errors[:image].any?
    end
  end

  test "is valid without any attached image" do
    dish = Dish.new(name: "Test", description: "Test", dish_type: :entrant)
    dish.ingredients << ingredients(:milk)
    assert dish.valid?
  end

  # ---- filter scopes ----

  test "of_types narrows to the listed dish types" do
    result = Dish.of_types([ "entrant" ])

    assert(result.all? { |d| d.dish_type == "entrant" })
    assert_includes result, dishes(:olivas)
    assert_includes result, dishes(:pan_tomáquet)
    assert_not_includes result, dishes(:paella)
  end

  test "of_types returns ::all when types are empty or nil" do
    assert_equal Dish.all.to_a.sort_by(&:id), Dish.of_types([]).to_a.sort_by(&:id)
    assert_equal Dish.all.to_a.sort_by(&:id), Dish.of_types(nil).to_a.sort_by(&:id)
  end

  test "with_restrictions returns dishes whose ingredients carry the restriction" do
    result = Dish.with_restrictions([ restrictions(:gluten).id ])

    assert_includes result, dishes(:olivas) # olivas -> bread (gluten)
    assert_not_includes result, dishes(:paella)
    assert_not_includes result, dishes(:gelat)
  end

  test "with_restrictions ORs across multiple ids and stays distinct" do
    result = Dish.with_restrictions([ restrictions(:gluten).id, restrictions(:lactose).id ])

    assert_includes result, dishes(:olivas)
    assert_includes result, dishes(:gelat) # gelat -> yogurt (lactose)
    assert_equal result.to_a.size, result.to_a.uniq.size
  end

  test "with_restrictions returns ::all when ids are empty or nil" do
    assert_equal Dish.all.to_a.sort_by(&:id), Dish.with_restrictions([]).to_a.sort_by(&:id)
    assert_equal Dish.all.to_a.sort_by(&:id), Dish.with_restrictions(nil).to_a.sort_by(&:id)
  end

  test "without_restrictions excludes dishes touching any listed restriction" do
    result = Dish.without_restrictions([ restrictions(:gluten).id ])

    assert_not_includes result, dishes(:olivas)
    assert_includes result, dishes(:paella)
    assert_includes result, dishes(:gelat)
  end

  test "without_restrictions keeps dishes whose ingredients carry no restriction at all" do
    # pollastre -> salt (no restriction). Must survive any exclude filter.
    result = Dish.without_restrictions([ restrictions(:gluten).id, restrictions(:lactose).id ])

    assert_includes result, dishes(:pollastre)
    assert_not_includes result, dishes(:olivas)
    assert_not_includes result, dishes(:gelat)
  end

  test "without_restrictions returns ::all when ids are empty or nil" do
    assert_equal Dish.all.to_a.sort_by(&:id), Dish.without_restrictions([]).to_a.sort_by(&:id)
    assert_equal Dish.all.to_a.sort_by(&:id), Dish.without_restrictions(nil).to_a.sort_by(&:id)
  end

  # ---- all_restrictions ----

  test "all_restrictions gathers restrictions from elaboration ingredients" do
    # lasanya has no direct ingredients; its only restriction (gluten) comes
    # from the bolognesa elaboration's bread ingredient.
    assert_equal [ restrictions(:gluten) ], dishes(:lasanya).all_restrictions
  end

  test "all_restrictions merges direct and elaboration sources without duplicates" do
    dish = dishes(:lasanya) # gluten via bolognesa elaboration -> bread
    dish.ingredients << ingredients(:bread) # gluten again, now directly

    assert_equal [ restrictions(:gluten) ], dish.all_restrictions
  end
end
