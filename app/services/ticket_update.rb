class TicketUpdate
  def initialize(ticket, actor:, status_notifier: TicketStatusBroadcaster.new)
    @ticket = ticket
    @actor = actor
    @status_notifier = status_notifier
  end

  def call(attributes)
    @ticket.assign_attributes(attributes)
    status_change = @ticket.status_change

    return false unless save_recording(status_change)

    @status_notifier.status_changed(@ticket) if status_change
    true
  end

  private
    def save_recording(status_change)
      Ticket.transaction do
        @ticket.save && record(status_change)
      end
    end

    def record(status_change)
      return true unless status_change

      from_status, to_status = status_change
      @ticket.status_changes.create!(actor: @actor, from_status: from_status, to_status: to_status)
    end
end
