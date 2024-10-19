# test/channels/notification_channel_test.rb

require "test_helper"

class WardenStub
  def initialize(user)
    @user = user
  end

  def user
    @user
  end
end

class NotificationChannelTest < ActionCable::Channel::TestCase
  test "subscribes to stream when user is connected" do
    # Load user from fixtures
    user = users(:admin_user)

    # Create a WardenStub instance with the authenticated user
    warden = WardenStub.new(user)

    # Simulate connection with the authenticated user
    stub_connection current_user: user, env: { "warden" => warden }

    # Subscribe to the channel
    subscribe

    # Verify that the subscription was successfully created
    assert subscription.confirmed?

    # Verify that the channel is streaming for the current user
    assert_has_stream_for user
  end

  test "rejects subscription when user is not authenticated" do
    # Create a WardenStub instance with no user
    warden = WardenStub.new(nil)

    # Simulate connection with no authenticated user
    stub_connection current_user: nil, env: { "warden" => warden }

    # Attempt to subscribe to the channel
    subscribe

    # Since the user is not authenticated, the subscription should be rejected
    assert subscription.rejected?
  end

  test "transmits data to the user" do
    # Load user from fixtures
    user = users(:admin_user)

    # Create a WardenStub instance with the authenticated user
    warden = WardenStub.new(user)

    # Simulate connection with the authenticated user
    stub_connection current_user: user, env: { "warden" => warden }

    # Subscribe to the channel
    subscribe

    # Verify that the subscription was successfully created
    assert subscription.confirmed?

    # Broadcast data to the channel
    data = { message: "New notification" }
    NotificationChannel.broadcast_to(user, data)

    # Verify that the data was transmitted to the user
    assert_broadcasts(user, 1)
    assert_broadcast_on(user, data)
  end
end
