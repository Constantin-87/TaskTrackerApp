require 'faye/websocket'
class Notification < ApplicationRecord
  belongs_to :user

  # Scope to get unread notifications
  scope :unread, -> { where(read: false) }

  # Only broadcast a notification to the user via WebSocket when created
  after_create_commit :broadcast_notification

  private

  def broadcast_notification
    Rails.logger.info "Notification Model: Broadcasting notification to user #{user.id} with message: #{message}"

    # Access any open WebSocket connections managed within your NotificationsController
    connection = Api::NotificationsController.connections[user.id]

    if connection
      # Send the notification message directly to the user's WebSocket connection
      connection.send({ message: message, id: id, read: read }.to_json)
    else
      Rails.logger.warn "No active WebSocket connection for user #{user.id}"
    end
  end
end