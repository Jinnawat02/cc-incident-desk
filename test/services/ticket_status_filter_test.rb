require "test_helper"

class TicketStatusFilterTest < ActiveSupport::TestCase
  test "selects all tickets when no status is given" do
    filter = TicketStatusFilter.new(Ticket.all, nil)

    assert filter.selected?("all")
    assert_equal Ticket.count, filter.tickets.count
  end

  test "falls back to all tickets for an unknown status" do
    filter = TicketStatusFilter.new(Ticket.all, "deleted")

    assert filter.selected?("all")
    assert_equal Ticket.count, filter.tickets.count
  end

  test "narrows tickets to the selected status" do
    filter = TicketStatusFilter.new(Ticket.all, "open")

    assert filter.selected?("open")
    assert_equal [ tickets(:checkout_error), tickets(:slow_login) ].sort, filter.tickets.sort
  end

  test "offers all and every status as options" do
    filter = TicketStatusFilter.new(Ticket.all, nil)

    assert_equal %w[ all open in_progress resolved ], filter.options
  end

  test "counts tickets per option within the scope" do
    filter = TicketStatusFilter.new(Ticket.all, "resolved")

    assert_equal 4, filter.count_for("all")
    assert_equal 2, filter.count_for("open")
    assert_equal 1, filter.count_for("in_progress")
    assert_equal 1, filter.count_for("resolved")
  end

  test "counts zero for a status with no tickets" do
    filter = TicketStatusFilter.new(Ticket.where(status: :open), nil)

    assert_equal 0, filter.count_for("resolved")
  end
end
