# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  # POST /api/users
  def create
    # Manually permit parameters in sign_up_params to ensure they are allowed
    user_params = sign_up_params

    build_resource(user_params)

    if resource.save
      # Generate JWT token upon successful registration
      token = JWT.encode({ sub: resource.id }, Rails.application.secret_key_base, 'HS256')

      # Send back token and user data as JSON response
      render json: {
        message: 'Signed up successfully.',
        token: token,
        user: resource.as_json(only: [:id, :email, :first_name, :last_name])  # Limit user data fields in response
      }, status: :created
    else
      # Send error messages if user creation failed
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  protected

  # Override sign_up_params to explicitly permit parameters
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
