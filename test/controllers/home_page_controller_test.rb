require "test_helper"

class HomePageControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
  end

  # Test for logged-in admin access to the home page
  test "should get home page as admin" do
    sign_in @admin_user
    get home_page_index_path  # Use the correct path for your home page
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  # Test for logged-in manager access to the home page
  test "should get home page as manager" do
    sign_in @manager_user
    get home_page_index_path  # Use the correct path for your home page
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  # Test for logged-in agent access to the home page
  test "should get home page as agent" do
    sign_in @agent_user
    get home_page_index_path  # Use the correct path for your home page
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  # Test that unauthorized users (not logged in) are redirected to login page
  test "should redirect unauthorized user to login" do
    get home_page_index_path  # Use the correct path for your home page
    assert_redirected_to new_user_session_path
  end
end
