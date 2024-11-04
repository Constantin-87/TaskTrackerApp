# app/controllers/api/users_controller.rb
module Api
  class UsersController < ApplicationController
    before_action :authenticate_devise_api_token!
    before_action :authorize_admin, only: [ :index, :destroy ] # Admin check except for create action
    before_action :set_user, only: [ :show, :update, :destroy ]
    before_action :authorize_profile_edit, only: [ :update ]

    # GET /api/users
    def index
      @users = User.all
      render json: {
        users: @users.as_json(only: [ :id, :first_name, :last_name, :email, :role ]),
        roles: User.roles.keys
      }
    end

    # GET /api/users/:id
    def show
      render json: @user.as_json(only: [ :id, :first_name, :last_name, :email, :role ])
    end

    # POST /api/users
    def create
      # Determine the role to assign
      role = current_user&.admin? ? user_params[:role] : "agent"

      @user = User.new(user_params.except(:role).merge(role: role))

      if @user.save
        render json: { message: "User created successfully", user: @user, token: token }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PUT /api/users/:id
    def update
      # Validate the current password if it's provided
      if params[:user][:current_password].present? && !current_devise_api_token.resource_owner.admin?
        unless @user.valid_password?(params[:user][:current_password])
          return render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
        end
      end

      # Attempt to update user details (excluding `current_password` from updates)
      if @user.update(user_params.except(:current_password))
        render json: { message: "User updated successfully", user: @user.as_json(only: [ :id, :first_name, :last_name, :email, :role ]) }
      else
        render json: { error: "Failed to update user", details: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/users/:id
    def destroy
      @user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    end

    private

    def authorize_admin
      render json: { error: "Not authorized" }, status: :forbidden unless current_devise_api_token&.resource_owner&.admin?
    end

    def authorize_profile_edit
      # Allow admins to edit any profile, or allow users to edit their own profile
      unless current_devise_api_token&.resource_owner&.admin? || current_devise_api_token&.resource_owner&.id == @user.id
        render json: { error: "You are not authorized to perform this action" }, status: :forbidden
      end
    end

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :not_found
    end

    def user_params
      permitted_params = [ :first_name, :last_name, :email, :password, :password_confirmation, :current_password ]
      permitted_params << :role if current_devise_api_token&.resource_owner&.admin?
      params.require(:user).permit(permitted_params)
    end
  end
end
