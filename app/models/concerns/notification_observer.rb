# app/models/concerns/notification_observer.rb
require "singleton"

class NotificationObserver
  include Singleton
  include Rails.application.routes.url_helpers

  def update(message, task)
    Rails.logger.info "NotificationObserver: Update called for Task #{task.id} with message: #{message}"

    if task.user.present?
       # Use `url_for` to construct the full task path with host
       task_link = task_link = "/api/home?task_id=#{task.id}"

      # Create a formatted notification message that includes the link
      notification_message = "#{message}: <a href='#{task_link}' data-turbo='false'>#{task.title}</a>"

      Rails.logger.info "Notification Observer: Creating notification for user #{task.user.id} with message: #{notification_message}"
      # Save the notification to the database for real-time WebSocket delivery
      Notification.create(user: task.user, message: notification_message)
    else
      Rails.logger.warn "Notification Observer: No user assigned to task #{task.id}, notification skipped."
    end
  end
end
