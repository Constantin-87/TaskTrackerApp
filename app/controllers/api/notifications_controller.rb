# app/controllers/api/notifications_controller.rb
module Api
  class NotificationsController < ApplicationController
    before_action :authenticate_devise_api_token!

    # Store active WebSocket connections
    @@connections ||= {}

    def self.connections
      @@connections
    end

    def index
      if Faye::WebSocket.websocket?(request.env)
        handle_websocket(request.env)
      else
        notifications = current_user.notifications.unread
        render json: notifications, status: :ok
      end
    end

    def update
      notification = current_user.notifications.find(params[:id])

      if notification.update(read: true)
        render json: { message: "Notification marked as read." }, status: :ok
      else
        render json: { error: "Failed to mark notification as read." }, status: :unprocessable_entity
      end
    end

    private

    def handle_websocket(env)
      ws = Faye::WebSocket.new(env)

      ws.on :open do |_event|
        Rails.logger.info "WebSocket connection opened for user #{current_user.id}"
        @@connections[current_user.id] = ws
      end

      ws.on :close do |_event|
        Rails.logger.info "WebSocket connection closed for user #{current_user.id}"
        @@connections.delete(current_user.id)
      end

      ws.rack_response
    end
  end
end
