class Ticket < ApplicationRecord
  belongs_to :creator, class_name: "User", inverse_of: :created_tickets
  belongs_to :assignee, class_name: "User", optional: true, inverse_of: :assigned_tickets

  enum :severity, { low: 0, medium: 1, high: 2, urgent: 3 }, validate: true
  enum :status, { open: 0, in_progress: 1, resolved: 2 }, default: :open, validate: true

  validates :title, presence: true, length: { minimum: 5 }
  validates :description, presence: true, length: { minimum: 10 }

  scope :recent_first, -> { order(created_at: :desc, id: :desc) }

  def high_priority?
    high? || urgent?
  end
end
