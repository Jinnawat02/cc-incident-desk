class TicketStatusBroadcaster
  def status_changed(ticket)
    streams_for(ticket).each do |stream|
      Turbo::StreamsChannel.broadcast_replace_later_to(
        *stream,
        targets: "[data-ticket-status-id='#{ticket.id}']",
        partial: "tickets/status_badge",
        locals: { ticket: ticket }
      )
    end
  end

  private
    def streams_for(ticket)
      [ [ ticket ], [ ticket.creator, :tickets ] ]
    end
end
