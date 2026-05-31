module SerfDesignHelper
  ICON_PATHS = {
    home: [ "M3 12l9-9 9 9", "M5 10v10h14V10" ],
    users: [
      "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",
      "M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8",
      "M22 21v-2a4 4 0 0 0-3-3.87",
      "M17 3.13a4 4 0 0 1 0 7.75"
    ],
    leaf: [
      "M11 20A7 7 0 0 1 4 13c0-7 8-9 16-9 0 8-2 16-9 16Z",
      "M2 22l9-9"
    ],
    forkknife: [
      "M3 2v7a3 3 0 0 0 3 3v10",
      "M9 2v7a3 3 0 0 1-3 3",
      "M14 2v20",
      "M14 7h4a3 3 0 0 1 0 6h-4"
    ],
    book: [
      "M4 19.5A2.5 2.5 0 0 1 6.5 17H20",
      "M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z"
    ],
    search: [ "M21 21l-4.3-4.3", "M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14Z" ],
    plus: [ "M12 5v14", "M5 12h14" ],
    filter: [ "M22 3H2l8 9.46V19l4 2v-8.54L22 3z" ],
    edit: [ "M17 3a2.85 2.85 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" ],
    trash: [
      "M3 6h18",
      "M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2",
      "M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"
    ],
    shield: [ "M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" ],
    bell: [
      "M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9",
      "M10.3 21a1.94 1.94 0 0 0 3.4 0"
    ],
    check: [ "M20 6L9 17l-5-5" ],
    x: [ "M18 6L6 18", "M6 6l18 12" ],
    chevron: [ "M9 18l6-6-6-6" ],
    chevron_left: [ "M15 18l-6-6 6-6" ],
    logout: [
      "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4",
      "M16 17l5-5-5-5",
      "M21 12H9"
    ],
    alert: [
      "M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z",
      "M12 9v4",
      "M12 17h.01"
    ],
    user: [
      "M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2",
      "M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z"
    ],
    eye: [
      "M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z",
      "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"
    ],
    eye_off: [
      "M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94",
      "M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19",
      "M14.12 14.12a3 3 0 1 1-4.24-4.24",
      "M1 1l22 22"
    ],
    lock: [
      "M19 11H5a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2z",
      "M7 11V7a5 5 0 0 1 10 0v4"
    ],
    phone: [
      "M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"
    ],
    trend: [ "M22 7l-9.5 9.5-5-5L1 18", "M16 7h6v6" ],
    grid: [ "M3 3h7v7H3z", "M14 3h7v7h-7z", "M14 14h7v7h-7z", "M3 14h7v7H3z" ],
    list: [ "M3 6h18", "M3 12h18", "M3 18h18" ],
    menu: [ "M3 6h18", "M3 12h18", "M3 18h18" ],
    chart: [ "M3 3v18h18", "M8 17v-5", "M13 17V8", "M18 17v-9" ]
  }.freeze

  # Render a Lucide-style outline SVG icon.
  # Usage: <%= serf_icon(:home) %>
  def serf_icon(name, size: 18, stroke: 2)
    paths = ICON_PATHS[name.to_sym] || []
    content_tag(:svg,
                viewBox: "0 0 24 24",
                width: size, height: size,
                fill: "none", stroke: "currentColor",
                "stroke-width": stroke,
                "stroke-linecap": "round",
                "stroke-linejoin": "round") do
      safe_join(paths.map { |d| tag.path(d: d) })
    end
  end

  # Render a primary/secondary/ghost/danger button.
  def serf_btn(label = nil, kind: :secondary, size: nil, icon: nil, **opts, &block)
    classes = [ "btn", "btn-#{kind}" ]
    classes << "btn-sm" if size == :sm
    classes << "btn-icon" if label.nil? && block.nil? && icon
    opts[:class] = [ classes, opts[:class] ].compact.flatten
    content = capture(&block) if block
    content ||= label
    body = safe_join([ icon ? serf_icon(icon) : nil, content ].compact)
    if opts[:href] || opts[:to]
      link_to(body, opts.delete(:href) || opts.delete(:to), opts)
    else
      content_tag(:button, body, opts)
    end
  end

  # Map a Restriction.restriction_type enum value to a tag class.
  def restriction_tag_kind(restriction)
    case restriction.restriction_type
    when "intolerance_allergy" then "allergen"
    when "diet" then "diet"
    else "preference"
    end
  end

  # Renders a breadcrumb suitable for use as a topbar subtitle.
  # Each crumb is a [label, path_or_nil] pair. A nil path means current page.
  def breadcrumb(*crumbs)
    crumbs = crumbs.compact
    return safe_join([]) if crumbs.empty?
    last_idx = crumbs.length - 1
    sep = content_tag(:span, "/", class: "breadcrumb-sep")
    parts = crumbs.each_with_index.map do |(label, path), idx|
      if idx == last_idx || path.nil?
        content_tag(:span, label, class: "breadcrumb-current")
      else
        link_to(label, path, class: "breadcrumb-link")
      end
    end
    content_tag(:nav, safe_join(parts, sep), class: "breadcrumb", "aria-label": t("breadcrumb.label"))
  end

  # Renders the grid/list view-toggle group as <a> links that preserve current params.
  def view_toggle(current_view, request, default_view: "grid")
    current = current_view.presence || default_view
    safe_join(%w[grid list].map do |kind|
      link_to(grid_or_list_link_params(request, kind, default_view),
              class: "view-toggle-btn #{'is-active' if current == kind}",
              title: t("views.#{kind}"),
              "aria-label": t("views.#{kind}")) do
        serf_icon(kind.to_sym)
      end
    end).then { |body| content_tag(:div, body, class: "view-toggle", role: "group") }
  end

  # Wraps a topbar in standard markup. Used in views via:
  #   <%= render "shared/topbar", title: t(...), subtitle: ..., actions: nil %>
  # but exposing it as a helper avoids the partial when only a string title is needed.
  def serf_topbar(title:, subtitle: nil, &block)
    content_tag(:header, class: "topbar") do
      title_html = content_tag(:div) do
        safe_join([
          content_tag(:h1, title, class: "topbar-title"),
          subtitle ? content_tag(:div, subtitle, class: "topbar-sub") : nil
        ].compact)
      end
      actions = capture(&block) if block_given?
      safe_join([ title_html, actions ].compact)
    end
  end


  # Build a link that cycles a value through three states inside a pair
  # of array params: neutral -> exclude -> include -> neutral. Used by
  # the ingredients filter chips. The chip's visible state reflects the
  # CURRENT list the target is in; the href points to the NEXT state.
  def cycle_param_link(label, target:, include_param:, exclude_param:, request:)
    target = target.to_s
    include_ids = Array(request.query_parameters[include_param]).map(&:to_s)
    exclude_ids = Array(request.query_parameters[exclude_param]).map(&:to_s)

    current_state, new_include, new_exclude =
      if include_ids.include?(target)
        [ "include", include_ids - [ target ], exclude_ids              ]
      elsif exclude_ids.include?(target)
        [ "exclude", include_ids + [ target ], exclude_ids - [ target ] ]
      else
        [ nil,       include_ids,              exclude_ids + [ target ] ]
      end

    new_params = request.query_parameters.except(include_param, exclude_param)
    new_params[include_param] = new_include if new_include.any?
    new_params[exclude_param] = new_exclude if new_exclude.any?
    path = new_params.empty? ? request.path : "#{request.path}?#{new_params.to_query}"

    link_to(
      label,
      path,
      class: [ "chip", ("chip-#{current_state}" if current_state) ].compact,
      "data-state": current_state,
      title: t("filters.next_action.#{current_state || 'neutral'}")
    )
  end

  # Build a link that toggles a value into / out of a single array
  # query param. Binary semantics (selected / not selected) — no
  # exclude state. Used by filter rows whose options are mutually
  # non-exclusive but where excluding a value makes no sense
  # (e.g. dish-type filter on the dishes index).
  def select_param_link(label, target:, param:, request:)
    target = target.to_s
    current = Array(request.query_parameters[param]).map(&:to_s)
    active = current.include?(target)
    next_values = active ? current - [ target ] : current + [ target ]

    new_params = request.query_parameters.except(param)
    new_params[param] = next_values if next_values.any?
    path = new_params.empty? ? request.path : "#{request.path}?#{new_params.to_query}"

    link_to(
      label,
      path,
      class: [ "chip", ("chip-include" if active) ].compact,
      "data-state": (active ? "include" : nil)
    )
  end

  private

  # Build the params hash for a view-toggle link: drops the view param when it
  # matches the default, otherwise sets it. Always preserves other params.
  def grid_or_list_link_params(request, kind, default_view)
    base = request.query_parameters.merge("view" => kind)
    base.delete("view") if kind == default_view
    base.empty? ? request.path : "#{request.path}?#{base.to_query}"
  end
end
