require "test_helper"

class SerfDesignHelperTest < ActionView::TestCase
  # cycle_param_link cycles a restriction id through three states inside
  # a pair of array query params: neutral -> exclude -> include -> neutral.

  def build_request(query_string = "")
    ActionDispatch::TestRequest.create(
      "PATH_INFO" => "/ingredients",
      "QUERY_STRING" => query_string
    )
  end

  def href_of(html)
    html.match(/href="([^"]+)"/)[1]
  end

  def data_state_of(html)
    match = html.match(/data-state="([^"]*)"/)
    match && match[1]
  end

  def title_of(html)
    html.match(/title="([^"]+)"/)[1]
  end

  def call_helper(request, target: "7")
    cycle_param_link(
      "Gluten",
      target: target,
      include_param: "include_restrictions",
      exclude_param: "exclude_restrictions",
      request: request
    )
  end

  test "neutral state transitions to exclude on click" do
    html = call_helper(build_request)

    assert_nil data_state_of(html)
    assert_equal "/ingredients?exclude_restrictions%5B%5D=7", href_of(html)
    assert_equal I18n.t("filters.next_action.neutral"), title_of(html)
  end

  test "exclude state transitions to include on click" do
    html = call_helper(build_request("exclude_restrictions%5B%5D=7"))

    assert_equal "exclude", data_state_of(html)
    assert_equal "/ingredients?include_restrictions%5B%5D=7", href_of(html)
    assert_equal I18n.t("filters.next_action.exclude"), title_of(html)
  end

  test "include state transitions to neutral on click and drops empty params" do
    html = call_helper(build_request("include_restrictions%5B%5D=7"))

    assert_equal "include", data_state_of(html)
    assert_equal "/ingredients", href_of(html)
    assert_equal I18n.t("filters.next_action.include"), title_of(html)
  end

  test "preserves unrelated query params across transitions" do
    html = call_helper(build_request("search=foo&view=grid"))
    url = href_of(html)

    assert_includes url, "search=foo"
    assert_includes url, "view=grid"
    assert_includes url, "exclude_restrictions%5B%5D=7"
  end

  test "cycling one restriction does not disturb other ids in the same list" do
    html = call_helper(
      build_request("exclude_restrictions%5B%5D=5&exclude_restrictions%5B%5D=7"),
      target: "7"
    )
    url = href_of(html)

    assert_includes url, "exclude_restrictions%5B%5D=5"
    assert_includes url, "include_restrictions%5B%5D=7"
    refute_includes url, "exclude_restrictions%5B%5D=7"
  end

  test "renders chip class with state modifier when active" do
    html = call_helper(build_request("include_restrictions%5B%5D=7"))

    assert_match(/class="chip chip-include"/, html)
  end

  test "renders chip class without state modifier when neutral" do
    html = call_helper(build_request)

    assert_match(/class="chip"/, html)
    refute_match(/chip-include|chip-exclude/, html)
  end

  # ---- select_param_link (binary toggle, single array param) ----

  def call_select_helper(request, target: "entrant", param: "dish_types")
    select_param_link("Entrant", target: target, param: param, request: request)
  end

  test "select_param_link: neutral target adds the value to the param" do
    html = call_select_helper(build_request)

    assert_nil data_state_of(html)
    assert_equal "/ingredients?dish_types%5B%5D=entrant", href_of(html)
  end

  test "select_param_link: active target removes the value from the param" do
    html = call_select_helper(build_request("dish_types%5B%5D=entrant"))

    assert_equal "include", data_state_of(html)
    # Only value -> empty param -> URL without query string
    assert_equal "/ingredients", href_of(html)
  end

  test "select_param_link: removing one value preserves the others" do
    html = call_select_helper(build_request("dish_types%5B%5D=entrant&dish_types%5B%5D=postre"))
    url = href_of(html)

    assert_includes url, "dish_types%5B%5D=postre"
    refute_includes url, "dish_types%5B%5D=entrant"
  end

  test "select_param_link: preserves unrelated query params" do
    html = call_select_helper(build_request("search=foo&view=grid"))
    url = href_of(html)

    assert_includes url, "search=foo"
    assert_includes url, "view=grid"
    assert_includes url, "dish_types%5B%5D=entrant"
  end

  test "select_param_link: renders chip-include class only when active" do
    active = call_select_helper(build_request("dish_types%5B%5D=entrant"))
    neutral = call_select_helper(build_request)

    assert_match(/class="chip chip-include"/, active)
    assert_match(/class="chip"/, neutral)
    refute_match(/chip-include/, neutral)
  end
end
