require "test_helper"

class TicketUpdateTest < ActiveSupport::TestCase
  class RecordingNotifier
    attr_reader :tickets

    def initialize
      @tickets = []
    end

    def status_changed(ticket)
      @tickets << ticket
    end
  end

  setup do
    @ticket = tickets(:slow_login)
    @agent = users(:agent)
    @notifier = RecordingNotifier.new
    @update = TicketUpdate.new(@ticket, actor: @agent, status_notifier: @notifier)
  end

  test "changes the status, records an event and notifies" do
    assert_difference -> { @ticket.status_changes.count }, 1 do
      assert @update.call(status: "in_progress")
    end

    assert @ticket.reload.in_progress?
    event = @ticket.status_changes.last
    assert_equal @agent, event.actor
    assert event.from_open?
    assert event.to_in_progress?
    assert_equal [ @ticket ], @notifier.tickets
  end

  test "assigning without a status change records no event and does not notify" do
    assert_no_difference -> { TicketStatusChange.count } do
      assert @update.call(status: "open", assignee_id: @agent.id)
    end

    assert_equal @agent, @ticket.reload.assignee
    assert_empty @notifier.tickets
  end

  test "rejects an unknown status without recording or notifying" do
    assert_no_difference -> { TicketStatusChange.count } do
      assert_not @update.call(status: "closed")
    end

    assert @ticket.reload.open?
    assert_empty @notifier.tickets
  end

  test "rejects a customer as assignee without changing the status" do
    assert_no_difference -> { TicketStatusChange.count } do
      assert_not @update.call(status: "resolved", assignee_id: users(:customer).id)
    end

    assert @ticket.reload.open?
    assert_nil @ticket.assignee
    assert_empty @notifier.tickets
  end
end
