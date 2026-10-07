class TicketEscalationJob < ApplicationJob
  queue_as :default

  def perform(ticket)
    TicketEscalation.new(ticket).call
  end
end
