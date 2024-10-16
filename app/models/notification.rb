class Notification < ApplicationRecord
  belongs_to :user

  # Scope to get unread notifications
  scope :unread, -> { where(read: false) }

  validates :message, presence: true
end
