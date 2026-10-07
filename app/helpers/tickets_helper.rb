module TicketsHelper
  def severity_badge(ticket)
    tag.span(ticket.severity.titleize, class: "sev sev-#{ticket.severity.dasherize}")
  end

  def status_badge(ticket)
    tag.span(ticket.status.titleize, class: "st st-#{ticket.status.dasherize}")
  end

  def ticket_number(ticket)
    "##{ticket.id}"
  end

  def ticket_timestamp(time)
    time.strftime("%b %-d, %H:%M")
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

  def severity_options
    Ticket.severities.keys.map { |severity| [ severity.titleize, severity ] }
  end
end
