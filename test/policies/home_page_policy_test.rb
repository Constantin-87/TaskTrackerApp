require "test_helper"

class HomePagePolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user) # Assuming you have an admin user fixture
    @manager_user = users(:manager_user) # Assuming you have a manager user fixture
    @agent_user = users(:agent_user) # Assuming you have an agent user fixture
    @guest_user = nil # Represents a guest user (not logged in)
  end

  def test_index_as_admin
    policy = HomePagePolicy.new(@admin_user, :home_page)
    assert policy.index?, "Admin should be able to access the home page"
  end

  def test_index_as_manager
    policy = HomePagePolicy.new(@manager_user, :home_page)
    assert policy.index?, "Manager should be able to access the home page"
  end

  def test_index_as_agent
    policy = HomePagePolicy.new(@agent_user, :home_page)
    assert policy.index?, "Agent should be able to access the home page"
  end

  def test_index_as_guest
    policy = HomePagePolicy.new(@guest_user, :home_page)
    assert_not policy.index?, "Guest (not logged in) should not be able to access the home page"
  end
end
