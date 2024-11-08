# File: test/controllers/notifications_controller_functional_test.rb
require "test_helper"

class Api::NotificationsControllerFunctionalTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @notification = notifications(:one)
  end

# Helper method to authenticate a user, returning the token and logging details for investigation
def authenticate_user(user, &block)
  token = Devise::Api::Token.create!(
    resource_owner: user,
    access_token: SecureRandom.hex(20),
    refresh_token: SecureRandom.hex(20),
    expires_in: 3600
  )

  Rails.logger.info "Generated access token for user #{user.id}: #{token.access_token}"

  # Add the token explicitly to the header in Authorization format
  headers = {
    "Authorization" => "Bearer #{token.access_token}",
    "Content-Type" => "application/json"
  }

  headers
end


  # Test `index` action with Devise API authentication
  test "index action returns notifications for authenticated user" do
    headers = authenticate_user(@admin_user)
    get api_notifications_path, headers: headers
    assert_response :ok

    notifications = JSON.parse(@response.body)
    assert notifications.is_a?(Array), "Expected notifications to be an array"
    assert_equal @admin_user.notifications.unread.count, notifications.size, "Expected correct count of unread notifications"
  end

  # Test `update` action for marking a notification as read
  test "update notification marks it as read" do
    authenticate_user(@admin_user) do |headers|
      Rails.logger.info "Sending PATCH request to /api/notifications/#{@notification.id} with headers: #{headers}"

      patch api_notification_path(@notification), headers: headers

      # Log response details
      Rails.logger.info "Response status: #{response.status}"
      Rails.logger.info "Response body: #{response.body}"

      assert_response :ok
      json_response = JSON.parse(@response.body)
      assert_equal "Notification marked as read.", json_response["message"]
    end
  end

  # Test unauthenticated access to `index` action
  test "unauthenticated access to index is forbidden" do
    Rails.logger.info "Sending unauthenticated GET request to /api/notifications"

    get api_notifications_path, headers: { "Content-Type" => "application/json" }

    # Log response details
    Rails.logger.info "Response status: #{response.status}"
    Rails.logger.info "Response body: #{response.body}"

    assert_response :unauthorized
  end
end
