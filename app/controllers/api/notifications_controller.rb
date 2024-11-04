# app/controllers/api/notifications_controller.rb
module Api
  class NotificationsController < ApplicationController
    before_action :authenticate_devise_api_token!, only: [ :index, :update ]

    # Store active WebSocket connections
    @@connections ||= {}

    def self.connections
      @@connections
    end

    def index
      Rails.logger.info("Entering NotificationsController#index")

      if Faye::WebSocket.websocket?(request.env)
        Rails.logger.info("WebSocket request detected")
        handle_websocket(request.env)
      else
        Rails.logger.info("Non-WebSocket request: checking notifications for #{current_devise_api_token&.resource_owner&.id || 'no user'}")

        if current_devise_api_token
          notifications = current_devise_api_token.resource_owner.notifications.unread
          Rails.logger.info("Found unread notifications: #{notifications.count}")
          render json: notifications, status: :ok
        else
          Rails.logger.warn("Failed to authenticate user for notifications")
          head :unauthorized
        end
      end
    end

    def update
      Rails.logger.info("Entering NotificationsController#update with notification ID #{params[:id]}")
      if current_devise_api_token
        notification = current_devise_api_token.resource_owner.notifications.find(params[:id])

        if notification.update(read: true)
          Rails.logger.info("Notification #{notification.id} marked as read for user #{current_devise_api_token.resource_owner.id}")
          render json: { message: "Notification marked as read." }, status: :ok
        else
          Rails.logger.error("Failed to mark notification #{notification.id} as read")
          render json: { error: "Failed to mark notification as read." }, status: :unprocessable_entity
        end
      else
        Rails.logger.warn("Unauthorized attempt to update notification")
        head :unauthorized
      end
    end

    private

    def handle_websocket(env)
      ws = Faye::WebSocket.new(env)
      user = current_devise_api_token&.resource_owner

      if user
        Rails.logger.info "WebSocket connection opened for user #{user.id}"
        @@connections[user.id] = ws
      else
        Rails.logger.warn("Failed to authenticate user for WebSocket connection")
      end

      ws.on :open do |_event|
        Rails.logger.info "WebSocket connection opened for user #{user.id}"
      end

      ws.on :close do |_event|
        Rails.logger.info "WebSocket connection closed for user #{user.id}"
        @@connections.delete(user.id)
      end

      ws.rack_response
    end

    def authenticate_devise_api_token!
      token = request.query_parameters["token"]
      Rails.logger.info("authenticate_devise_api_token! called with token: #{token}")

      self.current_devise_api_token = DeviseApiToken.find_by(token: token)

      if current_devise_api_token
        Rails.logger.info("Authentication successful for user #{current_devise_api_token.resource_owner.id}")
      else
        Rails.logger.warn("Authentication failed for token: #{token}")
      end
    end
  end
end
