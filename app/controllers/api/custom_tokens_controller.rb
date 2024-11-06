module Api
  class CustomTokensController < Devise::Api::TokensController
    private
    # Define the custom sign_up_params method to permit required parameters and convert to hash
    def sign_up_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation
      ).to_h
    end
  end
end
