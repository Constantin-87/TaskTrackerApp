module Api
  class CustomTokensController < Devise::Api::TokensController
    private

    # Define the custom sign_up_params method to permit required parameters and convert to hash
    def sign_up_params
      permitted_params = params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation).to_h

      # Add logs to inspect the permitted parameters
      Rails.logger.info "Sign up parameters: #{permitted_params.inspect}"

      permitted_params
    end
  end
end
