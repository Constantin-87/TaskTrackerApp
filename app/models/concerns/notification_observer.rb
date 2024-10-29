# app/models/concerns/notification_observer.rb
require 'singleton'

class NotificationObserver
  include Singleton
  include Rails.application.routes.url_helpers

  def notify(message, task)
    Rails.logger.info "NotificationObserver: Update called for Task #{task.id} with message: #{message}"
      
    if task.user.present?
      # Generate a link to the task using a path that can be handled by your React frontend.
       # Use `url_for` to construct the full task path with host
       task_link = task_link = "http://localhost:3000/home?task_id=#{task.id}"

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
  