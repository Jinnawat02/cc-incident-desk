class TicketStatusChange < ApplicationRecord
  belongs_to :ticket, inverse_of: :status_changes
  belongs_to :actor, class_name: "User"

  enum :from_status, Ticket.statuses, prefix: :from, validate: true
  enum :to_status, Ticket.statuses, prefix: :to, validate: true
end
