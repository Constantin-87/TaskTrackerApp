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
      if Faye::WebSocket.websocket?(request.env)
        if @current_user
          handle_websocket(request.env)
        else
          render status: :unauthorized and return
        end
      else
        respond_to do |format|
          format.json do
            if @current_devise_api_token
              notifications = @current_devise_api_token.resource_owner.notifications.unread
              render json: notifications, status: :ok
            else
              head :unauthorized
            end
          end
          format.any { head :not_acceptable }
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
      user = @current_user

      if user
        @@connections[user.id] = ws
      else
        ws.close
        return
      end

      ws.on :close do |_event|
        @@connections.delete(user.id)
        ws = nil
      end

      ws.on :error do |_event|
        Rails.logger.error "WebSocket error for user #{user.id}: #{_event.message}"
        ws.close
      end

      ws.rack_response
    end

    def authenticate_via_query_token!
      token = request.query_parameters["token"]
      if token.present?
        # Check if the token is valid by querying the internal Devise API method
        @current_devise_api_token = Devise::Api::Token.find_by(access_token: token)

        # Ensure the user is set if the token is valid
        if @current_devise_api_token
          @current_user = @current_devise_api_token.resource_owner
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
