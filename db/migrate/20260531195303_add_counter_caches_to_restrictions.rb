class AddCounterCachesToRestrictions < ActiveRecord::Migration[7.2]
  def up
    add_column :restrictions, :ingredients_count, :integer, null: false, default: 0
    add_column :restrictions, :elaborations_count, :integer, null: false, default: 0
    add_column :restrictions, :dishes_count, :integer, null: false, default: 0
    add_column :restrictions, :menus_count, :integer, null: false, default: 0

    Restriction.reset_column_information
    Restriction.find_each do |r|
      direct_dish_ids = Dish.joins(ingredients: :ingredient_restrictions)
                            .where(ingredient_restrictions: { restriction_id: r.id })
                            .distinct.pluck(:id)
      elab_dish_ids   = Dish.joins(elaborations: { ingredients: :ingredient_restrictions })
                            .where(ingredient_restrictions: { restriction_id: r.id })
                            .distinct.pluck(:id)
      direct_menu_ids = Menu.joins(dishes: { ingredients: :ingredient_restrictions })
                            .where(ingredient_restrictions: { restriction_id: r.id })
                            .distinct.pluck(:id)
      elab_menu_ids   = Menu.joins(dishes: { elaborations: { ingredients: :ingredient_restrictions } })
                            .where(ingredient_restrictions: { restriction_id: r.id })
                            .distinct.pluck(:id)

      r.update_columns(
        ingredients_count: IngredientRestriction.where(restriction_id: r.id).count,
        elaborations_count: Elaboration.joins(ingredients: :ingredient_restrictions)
                                       .where(ingredient_restrictions: { restriction_id: r.id })
                                       .distinct.count,
        dishes_count: (direct_dish_ids | elab_dish_ids).size,
        menus_count:  (direct_menu_ids | elab_menu_ids).size
      )
    end
  end

  def down
    remove_column :restrictions, :ingredients_count
    remove_column :restrictions, :elaborations_count
    remove_column :restrictions, :dishes_count
    remove_column :restrictions, :menus_count
  end
end
