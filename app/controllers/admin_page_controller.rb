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
    authorize :admin_page, :create?

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_page_index_path, notice: "User was successfully created." }
        format.turbo_stream { redirect_to admin_page_index_path, notice: "User was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "shared/form_errors", locals: { object: @user }), status: :unprocessable_entity }
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize :admin_page, :edit? # Only admins can edit users
  end

  def update
    @user = User.find(params[:id])
    authorize :admin_page, :update? # Only admins can update users
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to admin_page_index_path, notice: "User was successfully updated." }
        format.turbo_stream { redirect_to admin_page_index_path, notice: "User was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "shared/form_errors", locals: { object: @user }), status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    authorize :admin_page, :destroy? # Only admins can delete users
    if @user == current_user
      flash[:alert] = "You cannot delete your own account."
      redirect_to admin_page_index_path
    else
      @user.destroy
      if @user.destroy
        redirect_to admin_page_index_path, notice: "User was successfully deleted."
      else
        flash[:alert] = "Failed to delete the user."
        redirect_to admin_page_index_path
      end
    end
  end

  private

  def user_params
    # Permit first_name, last_name, email, role, and password fields, including password confirmation if present
    permitted_params = params.require(:user).permit(:first_name, :last_name, :email, :role)

    if params[:user][:password].present?
      permitted_params[:password] = params[:user][:password]
      permitted_params[:password_confirmation] = params[:user][:password_confirmation]
    end

    permitted_params
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(authenticated_root_path)
  end
end
