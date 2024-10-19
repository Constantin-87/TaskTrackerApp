require "test_helper"

class AdminPagePolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user)  # Assuming you have an admin user fixture
    @agent_user = users(:agent_user)  # Assuming you have a non-admin user fixture
    @policy = AdminPagePolicy
  end

  def test_index
    # Only admin should be able to access the index page
    assert @policy.new(@admin_user, :admin_page).index?
    assert_not @policy.new(@agent_user, :admin_page).index?
  end

  def test_create
    # Only admin should be able to create
    assert @policy.new(@admin_user, :admin_page).create?
    assert_not @policy.new(@agent_user, :admin_page).create?
  end

  def test_update
    # Only admin should be able to update
    assert @policy.new(@admin_user, :admin_page).update?
    assert_not @policy.new(@agent_user, :admin_page).update?
  end

  def test_destroy
    # Only admin should be able to destroy
    assert @policy.new(@admin_user, :admin_page).destroy?
    assert_not @policy.new(@agent_user, :admin_page).destroy?
  end
end
