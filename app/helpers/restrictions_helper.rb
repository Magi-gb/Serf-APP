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

  # Renders a sortable column header link for the restrictions catalog.
  # col       — the sort key (must be in SORTABLE_COLUMNS)
  # html_class — extra CSS classes on the <a> element (e.g. "rx-col-num" for right-aligned numeric cols)
  def rx_sort_link(label, col, current_sort:, current_dir:, base_params: {}, html_class: nil)
    is_active = current_sort == col
    next_dir  = (is_active && current_dir == "asc") ? "desc" : "asc"
    indicator = content_tag(:span,
                            is_active ? (current_dir == "asc" ? " ↑" : " ↓") : "",
                            class: "rx-sort-indicator")
    css = [ "rx-sort-link", ("is-active" if is_active), html_class ].compact.join(" ")
    link_to(restrictions_path(base_params.merge(sort: col, dir: next_dir)), class: css) do
      safe_join([ label, indicator ])
    end
  end
end
