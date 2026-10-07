require "test_helper"

class TicketEscalationTest < ActiveSupport::TestCase
  class FixedClock
    attr_reader :current

    def initialize(current)
      @current = current
    end
  end

  class RecordingNotifier
    attr_reader :tickets

    def initialize
      @tickets = []
    end

    def ticket_escalated(ticket)
      @tickets << ticket
    end
  end

  setup do
    @now = Time.zone.local(2026, 10, 7, 9, 30)
    @notifier = RecordingNotifier.new
    @ticket = tickets(:slow_login)
    @ticket.update!(severity: :urgent)
  end

  test "tags an open unassigned high priority ticket and notifies" do
    assert escalate(@ticket)

    assert_equal @now, @ticket.reload.escalated_at
    assert @ticket.overdue?
    assert_equal [ @ticket ], @notifier.tickets
  end

  test "leaves an assigned ticket alone" do
    @ticket.update!(assignee: users(:agent))

    assert_not escalate(@ticket)
    assert_nil @ticket.reload.escalated_at
    assert_empty @notifier.tickets
  end

  test "leaves a ticket that is no longer open alone" do
    @ticket.update!(status: :in_progress)

    assert_not escalate(@ticket)
    assert_nil @ticket.reload.escalated_at
  end

  test "leaves a ticket whose severity was lowered alone" do
    @ticket.update!(severity: :medium)

    assert_not escalate(@ticket)
    assert_nil @ticket.reload.escalated_at
  end

  test "does not escalate the same ticket twice" do
    earlier = 1.day.ago.change(usec: 0)
    @ticket.update!(escalated_at: earlier)

    assert_not escalate(@ticket)
    assert_equal earlier, @ticket.reload.escalated_at
    assert_empty @notifier.tickets
  end

  private
    def escalate(ticket)
      TicketEscalation.new(ticket, clock: FixedClock.new(@now), notifier: @notifier).call
    end
end
