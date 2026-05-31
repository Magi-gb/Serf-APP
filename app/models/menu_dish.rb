class MenuDish < ApplicationRecord
  belongs_to :menu
  belongs_to :dish

  validates :menu_id, uniqueness: { scope: :dish_id }

  after_commit :recalculate_restriction_counts, on: %i[create destroy]

  private

  def recalculate_restriction_counts
    Restriction.recalculate_all_cached_counts!
  end
end
