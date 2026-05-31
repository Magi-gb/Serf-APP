class IngredientRestriction < ApplicationRecord
  belongs_to :ingredient
  belongs_to :restriction, counter_cache: :ingredients_count

  validates :ingredient_id, uniqueness: { scope: :restriction_id }

  after_commit :recalculate_restriction_counts, on: %i[create destroy]

  private

  def recalculate_restriction_counts
    Restriction.recalculate_all_cached_counts!
  end
end
