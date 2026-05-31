module RestrictionsHelper
  # NOTE: This function is temporal for the demo. A final product should allow inserting the code.
  def restriction_code(restriction)
    words = restriction.name.to_s.strip.split.map { |w| w.gsub(/[^[:alpha:]]/, "") }.reject(&:empty?)
    if words.length == 1
      words.first.first(3).upcase
    else
      words.map { |w| w.first }.first(6).join.upcase
    end
  end
end
