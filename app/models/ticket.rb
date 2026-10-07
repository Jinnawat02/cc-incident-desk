class Ticket < ApplicationRecord
  belongs_to :creator, class_name: "User", inverse_of: :created_tickets
  belongs_to :assignee, class_name: "User", optional: true, inverse_of: :assigned_tickets
  has_many :comments, dependent: :destroy, inverse_of: :ticket
  has_many :status_changes, class_name: "TicketStatusChange", dependent: :destroy, inverse_of: :ticket

  enum :severity, { low: 0, medium: 1, high: 2, urgent: 3 }, validate: true
  enum :status, { open: 0, in_progress: 1, resolved: 2 }, default: :open, validate: true

  validates :title, presence: true, length: { minimum: 5 }
  validates :description, presence: true, length: { minimum: 10 }
  validate :assignee_must_be_an_agent

  scope :recent_first, -> { order(created_at: :desc, id: :desc) }

  def high_priority?
    high? || urgent?
  end

  private
    def assignee_must_be_an_agent
      errors.add(:assignee, "must be an agent") if assignee_id && !assignee&.agent?
    end
end
