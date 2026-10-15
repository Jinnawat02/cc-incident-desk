class User < ApplicationRecord
  rolify
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :role, inclusion: { in: Role::NAMES, message: "must be customer or agent" }

  after_save :assign_role, if: -> { @role }

  def role
    (@role || roles.first&.name)&.inquiry
  end

  def role=(name)
    @role = name.to_s
  end

  private
    def assign_role
      (Role::NAMES - [ @role ]).each { |name| remove_role name }
      add_role @role
      @role = nil
    end
end
