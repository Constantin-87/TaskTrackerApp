require "test_helper"

class AdminPageControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @user_to_edit = users(:agent_user) # A user to edit/delete during tests
  end

  # Testing Admin access to index
  test "should get index as admin" do
    sign_in @admin_user
    get admin_page_index_path
    assert_response :success
    assert_not_nil assigns(:users)
  end

  # Non-admin users should not access the index
  test "should not get index as manager" do
    sign_in @manager_user
    get admin_page_index_path
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not get index as agent" do
    sign_in @agent_user
    get admin_page_index_path
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # Testing new user creation
  test "should get new as admin" do
    sign_in @admin_user
    get new_admin_page_path
    assert_response :success
  end

  test "should not get new as manager" do
    sign_in @manager_user
    get new_admin_page_path
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should create user as admin" do
    sign_in @admin_user
    assert_difference("User.count", 1) do
      post admin_page_index_path, params: { user: { first_name: "New", last_name: "User", email: "newuser@example.com", role: :agent, password: "password", password_confirmation: "password" } }
    end
    assert_redirected_to admin_page_index_path
    assert_equal "User was successfully created.", flash[:notice]
  end

  # Only admins should create users
  test "should not create user as manager" do
    sign_in @manager_user
    assert_no_difference("User.count") do
      post admin_page_index_path, params: { user: { first_name: "New", last_name: "User", email: "newuser@example.com", role: :agent, password: "password", password_confirmation: "password" } }
    end
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # Testing editing a user
  test "should get edit as admin" do
    sign_in @admin_user
    get edit_admin_page_path(@user_to_edit)
    assert_response :success
  end

  test "should not get edit as manager" do
    sign_in @manager_user
    get edit_admin_page_path(@user_to_edit)
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # Updating a user as admin
  test "should update user as admin" do
    sign_in @admin_user
    patch admin_page_path(@user_to_edit), params: { user: { first_name: "Updated" } }
    assert_redirected_to admin_page_index_path
    @user_to_edit.reload
    assert_equal "Updated", @user_to_edit.first_name
    assert_equal "User was successfully updated.", flash[:notice]
  end

  # Only admins should update users
  test "should not update user as manager" do
    sign_in @manager_user
    patch admin_page_path(@user_to_edit), params: { user: { first_name: "Updated" } }
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # Testing delete as admin
  test "should delete user as admin" do
    sign_in @admin_user

    # Destroy dependent tasks/notifications first if they exist
    @user_to_delete = users(:agent_user)
    @user_to_delete.tasks.destroy_all
    @user_to_delete.notifications.destroy_all

    assert_difference("User.count", -1) do
      delete admin_page_path(@user_to_delete)
    end

    assert_redirected_to admin_page_index_path
    assert_equal "User was successfully deleted.", flash[:notice]
  end

  # Only admins should delete users
  test "should not delete user as manager" do
    sign_in @manager_user
    assert_no_difference("User.count") do
      delete admin_page_path(@user_to_edit)
    end
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # Prevent self-deletion
  test "should not allow admin to delete themselves" do
    sign_in @admin_user
    assert_no_difference("User.count") do
      delete admin_page_path(@admin_user)
    end
    assert_redirected_to admin_page_index_path
    assert_equal "You cannot delete your own account.", flash[:alert]
  end
end
