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

  def severity_options
    Ticket.severities.keys.map { |severity| [ severity.titleize, severity ] }
  end
end
