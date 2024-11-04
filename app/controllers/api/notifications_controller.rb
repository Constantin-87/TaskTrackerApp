# app/controllers/api/notifications_controller.rb
module Api
  class NotificationsController < ApplicationController
    before_action :authenticate_via_query_token!, only: [:index]

    # Store active WebSocket connections
    @@connections ||= {}

    def self.connections
      @@connections
    end

    def index
      if Faye::WebSocket.websocket?(request.env)
        authenticate_via_query_token!
        handle_websocket(request.env) if current_user
      else
        authenticate_devise_api_token!
        notifications = current_devise_api_token.resource_owner.notifications.unread
        render json: notifications, status: :ok
      end
    end

    def update
      notification = current_devise_api_token.resource_owner.notifications.find(params[:id])

      if notification.update(read: true)
        render json: { message: "Notification marked as read." }, status: :ok
      else
        render json: { error: "Failed to mark notification as read." }, status: :unprocessable_entity
      end
    end

    private

    def handle_websocket(env)
      ws = Faye::WebSocket.new(env)
      user = current_devise_api_token.resource_owner

      ws.on :open do |_event|
        Rails.logger.info "WebSocket connection opened for user #{user.id}"
        @@connections[user.id] = ws
      end

      ws.on :close do |_event|
        Rails.logger.info "WebSocket connection closed for user #{user.id}"
        @@connections.delete(user.id)
      end

      ws.rack_response
    end

    def authenticate_via_query_token!
      if request.query_parameters["token"]
        token = request.query_parameters["token"]
        self.current_devise_api_token = DeviseApiToken.find_by(token: token)
        
        if current_devise_api_token
          self.current_user = current_devise_api_token.resource_owner
          Rails.logger.info "Authenticated user #{current_user.id} via WebSocket token"
        else
          Rails.logger.warn "Token authentication failed. Invalid token: #{token}"
        end
      end

      head :unauthorized unless current_devise_api_token
    end


  end

end
