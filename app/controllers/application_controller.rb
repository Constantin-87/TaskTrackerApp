class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  include Pundit::Authorization
  include ActionController::MimeResponds

  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!, only: [ :restricted ]

  def restricted
    devise_api_token = current_devise_api_token

    if devise_api_token
      render json: { message: "you have logged in" }, status: :ok
    else
      render json: { message: "you are not logged in" }, status: :unauthorized
    end
  end

  # Handle Pundit authorization errors with JSON responses
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  def frontend_index
    Rails.logger.info "Serving frontend index"
    render file: Rails.root.join("public", "index.html")
  end

  # JSON response for unauthorized users
  def user_not_authorized
    Rails.logger.warn "Unauthorized access attempt detected"
    render json: { error: "You are not authorized to perform this action." }, status: :forbidden
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :email, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end
end
