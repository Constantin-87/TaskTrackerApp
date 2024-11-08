module Api
  class NotificationsController < ApplicationController
    before_action :authenticate_devise_api_token!, only: [ :index, :update ], unless: -> { Faye::WebSocket.websocket?(request.env) }
    before_action :authenticate_via_query_token!, only: [ :index ], if: -> { Faye::WebSocket.websocket?(request.env) }

    # Store active WebSocket connections
    @@connections ||= {}

    def self.connections
      @@connections
    end

    def index
      Rails.logger.info "NotificationsController#index endpoint hit"
      Rails.logger.info "WebSocket request: #{Faye::WebSocket.websocket?(request.env)}"
      Rails.logger.info "Authenticated user ID: #{@current_user&.id || 'None'}"
      Rails.logger.info "Authenticated via Devise token: #{@current_devise_api_token.present?}"

      if Faye::WebSocket.websocket?(request.env)
        handle_websocket(request.env) if @current_user
      else
        if @current_devise_api_token
          notifications = @current_devise_api_token.resource_owner.notifications.unread
          Rails.logger.info "Retrieved #{notifications.count} unread notifications for user #{@current_devise_api_token.resource_owner.id}"
          render json: notifications, status: :ok
        else
          Rails.logger.warn "Unauthorized access to index endpoint"
          head :unauthorized
        end
      end
    end

    def update
      if @current_devise_api_token
        notification = @current_devise_api_token.resource_owner.notifications.find(params[:id])

        if notification.update(read: true)
          render json: { message: "Notification marked as read." }, status: :ok
        else
          render json: { error: "Failed to mark notification as read." }, status: :unprocessable_entity
        end
      else
        head :unauthorized
      end
    end

    private

    def handle_websocket(env)
      ws = Faye::WebSocket.new(env)
      user = @current_devise_api_token&.resource_owner

      if user
        @@connections[user.id] = ws
        Rails.logger.info "WebSocket opened for user #{user.id}"
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

    def authenticate_via_query_token!
      token = request.query_parameters["token"]
      Rails.logger.info "Attempting to authenticate WebSocket with token: #{token}"
      if token.present?
        # Check if the token is valid by querying the internal Devise API method
        @current_devise_api_token = Devise::Api::Token.find_by(access_token: token)

        # Ensure the user is set if the token is valid
        if @current_devise_api_token
          @current_user = @current_devise_api_token.resource_owner
          Rails.logger.info "Token authentication successful. Authenticated user ID: #{@current_user.id}"
        else
          Rails.logger.warn "Token authentication failed. Invalid token: #{token}"
        end
      else
        Rails.logger.warn "No token provided in WebSocket connection"
      end

      unless @current_devise_api_token
        Rails.logger.warn "Unauthorized WebSocket access due to missing or invalid token."
        head :unauthorized
      end
    end
  end
end
