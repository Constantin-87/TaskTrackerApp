# test/channels/application_cable/connection_test.rb

require "test_helper"

class WardenStub
  def initialize(user)
    @user = user
  end

  def user
    @user
  end
end

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with verified user" do
    admin_user = users(:admin_user)
    warden = WardenStub.new(admin_user)
    connect env: { "warden" => warden }
    assert_equal admin_user, connection.current_user
  end

  test "rejects connection without a verified user" do
    warden = WardenStub.new(nil)
    assert_reject_connection { connect env: { "warden" => warden } }
  end
end
