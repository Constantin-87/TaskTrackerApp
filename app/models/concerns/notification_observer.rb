class NotificationObserver
  include Rails.application.routes.url_helpers

  def update(message, task)
    if task.user.present?
       # Create a link to the task on the home page with the specific task ID
      task_link = "<a href='#{Rails.application.routes.url_helpers.authenticated_root_path}#collapse#{task.id}' data-turbo='false'>#{task.title}</a>"

      # Send the notification to the assigned user
      Notification.create(user: task.user, message: "#{message}: #{task_link}")
    end
  end
end
  