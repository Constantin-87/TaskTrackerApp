# File: test/controllers/notifications_controller_test.rb
require "test_helper"

class Api::NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @notification = notifications(:one) # Assuming you have a fixture for a notification
  end

  # Helper method to mock authentication
  def mock_authenticate_user(user)
    token = Devise::Api::Token.create!(
      resource_owner: user,
      access_token: SecureRandom.hex(20),
      refresh_token: SecureRandom.hex(20),
      expires_in: 3600
    )
    # Return the token object for test setup
    token
  end

  # Test retrieving unread notifications for an authenticated user
  test "should get unread notifications for authenticated user" do
    token = mock_authenticate_user(@admin_user)
    get api_notifications_path, headers: { "Authorization" => "Bearer #{token.access_token}", "Content-Type" => "application/json" }
    assert_response :ok
    notifications = JSON.parse(response.body)
    assert notifications.is_a?(Array), "Expected notifications to be an array"
  end

  # Test marking a notification as read
  test "should mark notification as read" do
    token = mock_authenticate_user(@admin_user)
    patch api_notification_path(@notification), headers: { "Authorization" => "Bearer #{token.access_token}", "Content-Type" => "application/json" }
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Notification marked as read.", json_response["message"]

    # Verify that the notification was marked as read
    @notification.reload
    assert @notification.read?, "Notification should be marked as read"
  end

  # Unauthorized access test for updating notifications
  test "should not mark notification as read without authentication" do
    patch api_notification_path(@notification), headers: { "Content-Type" => "application/json" }
    assert_response :unauthorized
  end
end
