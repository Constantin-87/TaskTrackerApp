# app/controllers/admin_page_controller.rb
class AdminPageController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @users = User.all
    authorize :admin_page, :index? # Only admins can access
  end

  def new
    @user = User.new
    authorize :admin_page, :new? # Only admins can create users
  end

  def create
    @user = User.new(user_params)
    authorize :admin_page, :create? # Only admins can create users
    if @user.save
      redirect_to admin_page_index_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize :admin_page, :edit? # Only admins can edit users
  end

  def update
    @user = User.find(params[:id])
    authorize :admin_page, :update? # Only admins can update users
    if @user.update(user_params)
      redirect_to admin_page_index_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    
    if @user == current_user
      flash[:alert] = "You cannot delete your own account."
      redirect_to admin_page_index_path
    else
      authorize :admin_page, :destroy? # Only admins can delete users
      @user.destroy
      if @user.destroy
        redirect_to admin_page_index_path, notice: 'User was successfully deleted.'
      else
        flash[:alert] = "Failed to delete the user."
        redirect_to admin_page_index_path
      end
    end
  end

  private

  def user_params
    # Permit email, role, and password fields, but exclude password fields if blank
    params.require(:user).permit(:email, :role).tap do |user_params|
      if params[:user][:password].present?
        user_params[:password] = params[:user][:password]
        user_params[:password_confirmation] = params[:user][:password_confirmation]
      end
    end
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(root_path)
  end
end
