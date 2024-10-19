require "test_helper"

class TeamPolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user) # Assuming you have an admin user fixture
    @manager_user = users(:manager_user) # Assuming you have a manager user fixture
    @agent_user = users(:agent_user) # Assuming you have an agent user fixture
    @team = teams(:agentTeam) # Assuming you have a team fixture
  end

  def test_index_as_admin
    policy = TeamPolicy.new(@admin_user, Team)
    assert policy.index?, "Admin should be able to view the team index"
  end

  def test_index_as_non_admin
    policy = TeamPolicy.new(@manager_user, Team)
    assert_not policy.index?, "Non-admins should not be able to view the team index"
  end

  def test_create_as_admin
    policy = TeamPolicy.new(@admin_user, Team)
    assert policy.create?, "Admin should be able to create a team"
  end

  def test_create_as_non_admin
    policy = TeamPolicy.new(@manager_user, Team)
    assert_not policy.create?, "Non-admins should not be able to create a team"
  end

  def test_update_as_admin
    policy = TeamPolicy.new(@admin_user, @team)
    assert policy.update?, "Admin should be able to update the team"
  end

  def test_update_as_non_admin
    policy = TeamPolicy.new(@agent_user, @team)
    assert_not policy.update?, "Non-admins should not be able to update the team"
  end

  def test_destroy_as_admin
    policy = TeamPolicy.new(@admin_user, @team)
    assert policy.destroy?, "Admin should be able to destroy the team"
  end

  def test_destroy_as_non_admin
    policy = TeamPolicy.new(@agent_user, @team)
    assert_not policy.destroy?, "Non-admins should not be able to destroy the team"
  end

  def test_scope_as_admin
    scope = Pundit.policy_scope(@admin_user, Team)
    assert_equal Team.all, scope, "Admin should be able to view all teams"
  end

  def test_scope_as_non_admin
    scope = Pundit.policy_scope(@manager_user, Team)
    assert_nil scope, "Non-admins should not be able to view teams"
  end
end
