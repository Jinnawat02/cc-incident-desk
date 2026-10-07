class EscalationLogNotifier
  def initialize(logger: Rails.logger)
    @logger = logger
  end

  def ticket_escalated(ticket)
    @logger.warn(
      "[escalation] Ticket ##{ticket.id} \"#{ticket.title}\" (#{ticket.severity}) is overdue: " \
      "still open and unassigned since #{ticket.created_at.iso8601}"
    )
  end
end
