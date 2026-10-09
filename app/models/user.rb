class User < ApplicationRecord
  rolify
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validate :has_one_known_role

  def role
    roles.first&.name if roles.size == 1
  end

  def role=(name)
    self.roles = [ Role.find_or_initialize_by(name: name.to_s, resource_type: nil, resource_id: nil) ]
  end

  private
    def has_one_known_role
      errors.add(:role, "must be customer or agent") unless Role::NAMES.include?(role)
    end
end
