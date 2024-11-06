require "test_helper"

class TaskPolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @task = tasks(:one)
  end

  def test_index_as_admin
    policy = TaskPolicy.new(@admin_user, Task)
    assert policy.index?, "Admin should be able to view tasks"
  end

  def test_index_as_manager
    policy = TaskPolicy.new(@manager_user, Task)
    assert policy.index?, "Manager should be able to view tasks"
  end

  def test_index_as_agent
    policy = TaskPolicy.new(@agent_user, Task)
    assert policy.index?, "Agent should be able to view tasks"
  end

  def test_create_as_admin
    policy = TaskPolicy.new(@admin_user, Task)
    assert policy.create?, "Admin should be able to create a task"
  end

  def test_create_as_manager
    policy = TaskPolicy.new(@manager_user, Task)
    assert policy.create?, "Manager should be able to create a task"
  end

  def test_create_as_agent
    policy = TaskPolicy.new(@agent_user, Task)
    assert_not policy.create?, "Agent should not be able to create a task"
  end

  def test_update_as_admin
    policy = TaskPolicy.new(@admin_user, @task)
    assert policy.update?, "Admin should be able to update the task"
  end

  def test_update_as_manager
    policy = TaskPolicy.new(@manager_user, @task)
    assert policy.update?, "Manager should be able to update the task"
  end

  def test_update_as_agent
    policy = TaskPolicy.new(@agent_user, @task)
    assert_not policy.update?, "Agent should not be able to update the task"
  end

  def test_destroy_as_admin
    policy = TaskPolicy.new(@admin_user, @task)
    assert policy.destroy?, "Admin should be able to destroy the task"
  end

  def test_destroy_as_manager
    policy = TaskPolicy.new(@manager_user, @task)
    assert_not policy.destroy?, "Manager should not be able to destroy the task"
  end

  def test_destroy_as_agent
    policy = TaskPolicy.new(@agent_user, @task)
    assert_not policy.destroy?, "Agent should not be able to destroy the task"
  end
end
