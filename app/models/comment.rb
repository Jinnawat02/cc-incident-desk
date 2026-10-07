class Comment < ApplicationRecord
  belongs_to :ticket, inverse_of: :comments
  belongs_to :author, class_name: "User", inverse_of: :comments

  validates :body, presence: true, length: { maximum: 10_000 }

  scope :chronological, -> { order(:created_at, :id) }
end
