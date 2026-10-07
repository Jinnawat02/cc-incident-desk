require "test_helper"

class TicketTest < ActiveSupport::TestCase
  setup do
    @ticket = Ticket.new(
      title: "Printer is on fire",
      description: "Smoke is coming out of the office printer.",
      severity: :urgent,
      creator: users(:customer)
    )
  end

  test "is valid with a title, description, severity and creator" do
    assert @ticket.valid?
  end

  test "defaults to the open status" do
    assert @ticket.open?
  end

  test "has no assignee by default" do
    assert_nil @ticket.assignee
  end

  test "requires a title of at least 5 characters" do
    @ticket.title = "Oops"

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:title], "is too short (minimum is 5 characters)"
  end

  test "requires a description of at least 10 characters" do
    @ticket.description = "Broken"

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:description], "is too short (minimum is 10 characters)"
  end

  test "requires a known severity" do
    @ticket.severity = "catastrophic"

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:severity], "is not included in the list"
  end

  test "requires a severity" do
    @ticket.severity = nil

    assert_not @ticket.valid?
    assert_includes @ticket.errors[:severity], "is not included in the list"
  end

  test "requires a creator" do
    @ticket.creator = nil

    assert_not @ticket.valid?
  end

  test "recent_first orders newest tickets first" do
    newest = tickets(:slow_login)
    newest.update!(created_at: 1.minute.from_now)

    assert_equal newest, Ticket.recent_first.first
  end

  test "high and urgent tickets are high priority" do
    assert tickets(:export_failure).high_priority?
    assert tickets(:checkout_error).high_priority?
    assert_not tickets(:slow_login).high_priority?
    assert_not tickets(:invoice_typo).high_priority?
  end
end
