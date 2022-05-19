require "application_system_test_case"

class DateRangesTest < ApplicationSystemTestCase
  setup do
    @date_range = date_ranges(:one)
  end

  test "visiting the index" do
    visit date_ranges_url
    assert_selector "h1", text: "Date ranges"
  end

  test "should create date range" do
    visit date_ranges_url
    click_on "New date range"

    fill_in "Created by", with: @date_range.created_by
    fill_in "End date", with: @date_range.end_date
    fill_in "Start date", with: @date_range.start_date
    fill_in "User", with: @date_range.user_id
    click_on "Create Date range"

    assert_text "Date range was successfully created"
    click_on "Back"
  end

  test "should update Date range" do
    visit date_range_url(@date_range)
    click_on "Edit this date range", match: :first

    fill_in "Created by", with: @date_range.created_by
    fill_in "End date", with: @date_range.end_date
    fill_in "Start date", with: @date_range.start_date
    fill_in "User", with: @date_range.user_id
    click_on "Update Date range"

    assert_text "Date range was successfully updated"
    click_on "Back"
  end

  test "should destroy Date range" do
    visit date_range_url(@date_range)
    click_on "Destroy this date range", match: :first

    assert_text "Date range was successfully destroyed"
  end
end
