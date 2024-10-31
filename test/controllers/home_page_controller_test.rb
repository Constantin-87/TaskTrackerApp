require "test_helper"

class Api::HomePageControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
  end

  # Test for logged-in admin access to the home page
  test "should get home page as admin" do
    sign_in @admin_user
    get api_home_page_path, headers: { "Content-Type": "application/json" }  # Adjusted path to correct helper
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["tasks"].present?, "Expected tasks to be present in response"
  end

  # Test for logged-in manager access to the home page
  test "should get home page as manager" do
    sign_in @manager_user
    get api_home_page_path, headers: { "Content-Type": "application/json" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["tasks"].present?, "Expected tasks to be present in response"
  end

  # Test for logged-in agent access to the home page
  test "should get home page as agent" do
    sign_in @agent_user
    get api_home_page_path, headers: { "Content-Type": "application/json" }
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["tasks"].present?, "Expected tasks to be present in response"
  end

  # Test that unauthorized users (not logged in) are redirected to login page
  test "should return unauthorized status for unauthenticated access" do
    get api_home_page_path, headers: { "Content-Type": "application/json" }
    assert_response :unauthorized
  end
end
