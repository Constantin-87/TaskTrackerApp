class ApplicationController < ActionController::API
  include Pundit::Authorization

  # Handle Pundit authorization errors with JSON responses
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Custom JWT authentication before every request, unless Devise controller
  before_action :verify_jwt_token, unless: -> { devise_controller? || action_name == 'create' }

  # Allow custom parameters for Devise controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Custom logging for JWT token decoding
  before_action :log_jwt_token

  def frontend_index
    Rails.logger.info "Serving frontend index"
    render file: Rails.root.join("public", "index.html")
  end

  # JSON response for unauthorized users
  def user_not_authorized
    Rails.logger.warn "Unauthorized access attempt detected"
    render json: { error: "You are not authorized to perform this action." }, status: :forbidden
  end


  private

  def verify_jwt_token
    token = request.headers['Authorization']&.split(' ')&.last

    if token.present?
      Rails.logger.info "JWT Token received: #{token}"

      begin
        # Decode the JWT token
        decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
        Rails.logger.info "Decoded JWT token: #{decoded_token.inspect}"

        # Look up the user using the 'sub' field, which contains the user ID
        user_id = decoded_token[0]['sub']
        user = User.find_by(id: user_id)

        unless @current_user
          Rails.logger.error "No user found for decoded JWT"
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end

      rescue JWT::DecodeError => e
        Rails.logger.error "JWT Decode Error: #{e.message}"
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      Rails.logger.info "No JWT token provided in the request"
      render json: { error: 'No token provided' }, status: :unauthorized
    end
  end

  # Log the JWT token being sent to the server
  def log_jwt_token
    token = request.headers['Authorization']&.split(' ')&.last
    if token.present?
      begin
        decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
        Rails.logger.info "Decoded JWT: #{decoded_token}"
      rescue JWT::ExpiredSignature
        Rails.logger.error 'JWT token has expired'
      rescue JWT::DecodeError
        Rails.logger.error 'Invalid JWT token'
      end
    else
      Rails.logger.info 'No JWT token provided'
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end
end
