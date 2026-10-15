class Role < ApplicationRecord
  NAMES = %w[ customer agent ]

  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true, optional: true

  validates :name, inclusion: { in: NAMES }
  validates :resource_type, inclusion: { in: Rolify.resource_types }, allow_nil: true

  scopify
end
