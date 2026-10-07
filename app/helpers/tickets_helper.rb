module TicketsHelper
  def severity_badge(ticket)
    tag.span(ticket.severity.titleize, class: "sev sev-#{ticket.severity.dasherize}")
  end

  def status_badge(ticket)
    tag.span(ticket.status.titleize, class: "st st-#{ticket.status.dasherize}", data: { ticket_status_id: ticket.id })
  end

  def ticket_number(ticket)
    "##{ticket.id}"
  end

  def ticket_timestamp(time)
    time.strftime("%b %-d, %H:%M")
  end

  def ticket_opened_line(ticket)
    created = ticket_timestamp(ticket.created_at)
    Current.user.agent? ? "Opened by #{ticket.creator.email_address} · #{created}" : "Created #{created}"
  end

  def ticket_row_class(ticket)
    "row-#{ticket.severity}" if ticket.high_priority?
  end

  def assignee_label(ticket)
    if ticket.assignee
      ticket.assignee.email_address
    else
      tag.span("Unassigned", class: "unassigned")
    end
  end

  def status_options
    Ticket.statuses.keys.map { |status| [ status.titleize, status ] }
  end

  def assignee_options
    User.agent.order(:email_address).pluck(:email_address, :id)
  end

  def severity_options
    Ticket.severities.keys.map { |severity| [ severity.titleize, severity ] }
  end
end
