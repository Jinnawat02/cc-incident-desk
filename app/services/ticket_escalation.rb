class TicketEscalation
  def initialize(ticket, clock: Time, notifier: EscalationLogNotifier.new)
    @ticket = ticket
    @clock = clock
    @notifier = notifier
  end

  def call
    return false unless @ticket.escalatable?

    @ticket.update!(escalated_at: @clock.current)
    @notifier.ticket_escalated(@ticket)
    true
  end
end
