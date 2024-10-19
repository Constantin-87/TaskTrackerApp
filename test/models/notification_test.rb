# test/models/notification_test.rb

require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  def setup
    @user = users(:admin_user) # Adjust according to your fixtures
    @valid_attributes = {
      user: @user,
      message: "This is a test notification"
    }
  end

  test "should save valid notification" do
    notification = Notification.new(@valid_attributes)
    assert notification.save, "Failed to save a valid notification"
  end

  test "should not save notification without message" do
    notification = Notification.new(@valid_attributes.merge(message: ""))
    assert_not notification.save, "Saved the notification without a message"
    assert_includes notification.errors[:message], "can't be blank"
  end

  test "should not save notification without user" do
    notification = Notification.new(@valid_attributes.merge(user: nil))
    assert_not notification.save, "Saved the notification without a user"
    assert_includes notification.errors[:user], "must exist"
  end

  test "unread scope returns only unread notifications" do
    read_notification = Notification.create!(@valid_attributes.merge(read: true))
    unread_notification = Notification.create!(@valid_attributes.merge(read: false))

    unread_notifications = Notification.unread
    assert_includes unread_notifications, unread_notification
    assert_not_includes unread_notifications, read_notification
  end

  test "should broadcast notification after create" do
    notification = Notification.new(@valid_attributes)

    assert_broadcast_on(NotificationChannel.broadcasting_for(@user), message: notification.message) do
      notification.save! # Save to trigger the after_create_commit callback
    end
  end
end
