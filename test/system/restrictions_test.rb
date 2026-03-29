require "application_system_test_case"

class RestrictionsTest < ApplicationSystemTestCase
  setup do
    @restriction = restrictions(:one)
  end

  test "visiting the index" do
    visit restrictions_url
    assert_selector "h1", text: "Restrictions"
  end

  test "should create restriction" do
    visit restrictions_url
    click_on "New restriction"

    fill_in "Bg color", with: @restriction.bg_color
    fill_in "Description", with: @restriction.description
    fill_in "Name", with: @restriction.name
    click_on "Create Restriction"

    assert_text "Restriction was successfully created"
    click_on "Back"
  end

  test "should update Restriction" do
    visit restriction_url(@restriction)
    click_on "Edit this restriction", match: :first

    fill_in "Bg color", with: @restriction.bg_color
    fill_in "Description", with: @restriction.description
    fill_in "Name", with: @restriction.name
    click_on "Update Restriction"

    assert_text "Restriction was successfully updated"
    click_on "Back"
  end

  test "should destroy Restriction" do
    visit restriction_url(@restriction)
    click_on "Destroy this restriction", match: :first

    assert_text "Restriction was successfully destroyed"
  end
end
