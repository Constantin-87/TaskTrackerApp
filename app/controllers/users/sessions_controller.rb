# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json



  def create
    super do |resource|
      token = request.env["warden-jwt_auth.token"]
      Rails.logger.info "JWT Token issued for user #{resource.email}: #{token}"  # Log token creation
      response.set_header("Authorization", "Bearer #{token}")
      render json: {
        success: true,
        message: "Logged in successfully.",
        user: {
          id: resource.id,
          email: resource.email,
          first_name: resource.first_name,
          role: resource.role
        }
      } and return
    end
  end

  def destroy
    if user_signed_in?
      Rails.logger.info "Logging out user: #{current_user&.email || 'No email'}"
      begin
        sign_out(current_user)
        Rails.logger.info "User logged out successfully. Revoking JWT token."
        render json: { success: true, message: "Logged out successfully." }, status: :ok
      rescue => e
        Rails.logger.error "Error during logout: #{e.message}"
        render json: { error: "Logout failed due to an internal error." }, status: :internal_server_error
      end
    else
      Rails.logger.warn "Logout attempt without an active session"
      render json: { success: false, message: "No user logged in." }, status: :unauthorized
    end
  end




  # # POST /resource/sign_in
  # def create
  #   user = User.find_by(email: params[:user][:email])

  #   if user&.valid_password?(params[:user][:password])
  #     sign_in(user)

  #     # Manually set the Authorization header with the JWT token
  #     token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  #     Rails.logger.info "JWT token issued for user #{user.email}: #{token}"
  #     response.set_header('Authorization', "Bearer #{token}")

  #     render json: {
  #       success: true,
  #       message: 'Logged in successfully.',
  #       user: {
  #         id: user.id,
  #         email: user.email,
  #         first_name: user.first_name,  # Ensure user has first_name
  #         role: user.role  # Ensure user has role
  #       }
  #     }, status: :ok
  #   else
  #     render json: {
  #       success: false,
  #       message: 'Invalid email or password.'
  #     }, status: :unauthorized
  #   end
  # end

  # # DELETE /resource/sign_out
  # def destroy
  #   if user_signed_in?
  #     sign_out(current_user)

  #     render json: {
  #       success: true,
  #       message: 'Logged out successfully.'
  #     }, status: :ok
  #   else
  #     render json: {
  #       success: false,
  #       message: 'No user logged in.'
  #     }, status: :unauthorized
  #   end
  # end

  # protected

  # # Disable CSRF tokens for JSON requests (optional for API-only mode)
  # def verify_signed_out_user; end
end
