require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  def setup
    @user = users(:admin_user) # Uses the admin user from the fixture
    @valid_attributes = {
      user: @user,
      message: "This is a test notification",
      read: false
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
    read_notification = notifications(:two) # :two is read
    unread_notification = notifications(:one) # :one is unread

    unread_notifications = Notification.unread
    assert_includes unread_notifications, unread_notification
    assert_not_includes unread_notifications, read_notification
  end
end
