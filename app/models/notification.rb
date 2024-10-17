class Notification < ApplicationRecord
  belongs_to :user

  # Scope to get unread notifications
  scope :unread, -> { where(read: false) }

  validates :message, presence: true

  # Broadcast to the NotificationsChannel after the notification is created
  after_create_commit do
    NotificationChannel.broadcast_to(user, message: self.message)
  end

end
