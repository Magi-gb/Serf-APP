class DishIngredient < ApplicationRecord
  belongs_to :dish
  belongs_to :ingredient

  validates :dish_id, uniqueness: { scope: :ingredient_id }

  after_commit :recalculate_restriction_counts, on: %i[create destroy]

  private

  def recalculate_restriction_counts
    Restriction.recalculate_all_cached_counts!
  end
end
