class ElaborationIngredient < ApplicationRecord
  belongs_to :elaboration
  belongs_to :ingredient

  after_commit :recalculate_restriction_counts, on: %i[create destroy]

  private

  def recalculate_restriction_counts
    Restriction.recalculate_all_cached_counts!
  end
end
