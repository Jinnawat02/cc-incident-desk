require "test_helper"

class TicketEscalationJobTest < ActiveJob::TestCase
  test "escalates a ticket still open and unassigned" do
    ticket = tickets(:slow_login)
    ticket.update!(severity: :high)

    TicketEscalationJob.perform_now(ticket)

    assert ticket.reload.overdue?
  end

  test "does nothing once the ticket has an assignee" do
    ticket = tickets(:export_failure)

    TicketEscalationJob.perform_now(ticket)

    assert_nil ticket.reload.escalated_at
  end

  test "is discarded when the ticket no longer exists" do
    ticket = tickets(:slow_login)
    ticket.update!(severity: :urgent)
    TicketEscalationJob.perform_later(ticket)
    ticket.destroy!

    assert_nothing_raised { perform_enqueued_jobs }
  end

  test "uses the default queue" do
    assert_equal "default", TicketEscalationJob.new.queue_name
  end
end
