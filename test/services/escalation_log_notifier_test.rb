require "test_helper"

class EscalationLogNotifierTest < ActiveSupport::TestCase
  test "logs a warning naming the overdue ticket" do
    output = StringIO.new
    ticket = tickets(:checkout_error)

    EscalationLogNotifier.new(logger: Logger.new(output)).ticket_escalated(ticket)

    assert_match "WARN", output.string
    assert_match "[escalation] Ticket ##{ticket.id} \"Checkout returns 500 error\" (urgent) is overdue", output.string
  end
end
