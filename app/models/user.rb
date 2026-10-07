class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :created_tickets, class_name: "Ticket", foreign_key: :creator_id, inverse_of: :creator, dependent: :destroy
  has_many :comments, foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify

  enum :role, { customer: 0, agent: 1 }, default: :customer, validate: true

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def visible_tickets
    agent? ? Ticket.all : created_tickets
  end
end
