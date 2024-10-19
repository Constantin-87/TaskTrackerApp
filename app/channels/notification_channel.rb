class NotificationChannel < ApplicationCable::Channel
  def subscribed
    if current_user.present?
      stream_for current_user
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
