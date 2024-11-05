# app/models/concerns/notification_observer.rb
require "singleton"

class NotificationObserver
  include Singleton
  include Rails.application.routes.url_helpers

  def update(message, task)
    if task.user.present?
       task_link = task_link = "/home?task_id=#{task.id}"

      # Create a formatted notification message that includes the link
      notification_message = "#{message}: <a href='#{task_link}' data-turbo='false'>#{task.title}</a>"

      # Save the notification to the database for real-time WebSocket delivery
      Notification.create(user: task.user, message: notification_message)
    else
      Rails.logger.warn "Notification Observer: No user assigned to task #{task.id}, notification skipped."
    end
  end
end
