class User < ApplicationRecord
  ROLES = %w[ customer agent ].freeze

  rolify
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :must_have_exactly_one_role

  def role
    roles.first&.name
  end

  private
    def must_have_exactly_one_role
      names = roles.map(&:name)
      unless names.one? && ROLES.include?(names.first)
        errors.add(:role, "must be one of: #{ROLES.to_sentence(two_words_connector: " or ", last_word_connector: ", or ")}")
      end
    end
end
