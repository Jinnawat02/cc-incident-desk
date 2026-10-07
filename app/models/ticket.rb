class Ticket < ApplicationRecord
  ESCALATION_DELAY = 15.minutes

  belongs_to :creator, class_name: "User", inverse_of: :created_tickets
  belongs_to :assignee, class_name: "User", optional: true, inverse_of: :assigned_tickets
  has_many :comments, dependent: :destroy, inverse_of: :ticket
  has_many :status_changes, class_name: "TicketStatusChange", dependent: :destroy, inverse_of: :ticket

  enum :severity, { low: 0, medium: 1, high: 2, urgent: 3 }, validate: true
  enum :status, { open: 0, in_progress: 1, resolved: 2 }, default: :open, validate: true

  validates :title, presence: true, length: { minimum: 5 }
  validates :description, presence: true, length: { minimum: 10 }
  validate :assignee_must_be_an_agent

  after_create_commit :schedule_escalation, if: :high_priority?

  scope :recent_first, -> { order(created_at: :desc, id: :desc) }

  def high_priority?
    high? || urgent?
  end

  def unassigned?
    assignee_id.nil?
  end

  def escalated?
    escalated_at.present?
  end

  def escalatable?
    high_priority? && open? && unassigned? && !escalated?
  end

  def overdue?
    escalated? && open? && unassigned?
  end

  private
    def assignee_must_be_an_agent
      errors.add(:assignee, "must be an agent") if assignee_id && !assignee&.agent?
    end

    def schedule_escalation
      TicketEscalationJob.set(wait: ESCALATION_DELAY).perform_later(self)
    end
end
