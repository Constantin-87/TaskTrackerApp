class Notification < ApplicationRecord
  belongs_to :user

  # Scope to get unread notifications
  scope :unread, -> { where(read: false) }

  validates :message, presence: true

  # Broadcast to the NotificationsChannel after the notification is created
  after_create_commit :broadcast_notification

  private

  # Method to broadcast the notification and mark it as read
  def broadcast_notification
    NotificationChannel.broadcast_to(user, message: self.message)
  end
end
