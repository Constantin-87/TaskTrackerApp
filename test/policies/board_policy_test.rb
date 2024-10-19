require "test_helper"

class BoardPolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @board = boards(:agentBoard)
    @managerBoard = boards(:managerBoard)
  end

  def test_index_as_admin
    policy = BoardPolicy.new(@admin_user, Board)
    assert policy.index?, "Admin should be able to access the index"
  end

  def test_index_as_manager
    policy = BoardPolicy.new(@manager_user, Board)
    assert policy.index?, "Manager should be able to access the index"
  end

  def test_index_as_agent
    policy = BoardPolicy.new(@agent_user, Board)
    assert policy.index?, "Agent should be able to access the index"
  end

  def test_show_as_admin
    policy = BoardPolicy.new(@admin_user, @board)
    assert policy.show?, "Admin should be able to view the board"
  end

  def test_show_as_manager_with_access
    @manager_user.teams << @board.team
    policy = BoardPolicy.new(@manager_user, @board)
    assert policy.show?, "Manager with access to the team should be able to view the board"
  end

  def test_show_as_agent_with_access
    @agent_user.teams << @board.team
    policy = BoardPolicy.new(@agent_user, @board)
    assert policy.show?, "Agent with access to the team should be able to view the board"
  end

  def test_show_as_agent_without_access
    policy = BoardPolicy.new(@agent_user, @managerBoard)
    assert_not policy.show?, "Agent without access to the team should not be able to view the board"
  end

  def test_new_as_admin
    policy = BoardPolicy.new(@admin_user, Board)
    assert policy.new?, "Admin should be able to create a new board"
  end

  def test_new_as_manager
    policy = BoardPolicy.new(@manager_user, Board)
    assert policy.new?, "Manager should be able to create a new board"
  end

  def test_new_as_agent
    policy = BoardPolicy.new(@agent_user, Board)
    assert_not policy.new?, "Agent should not be able to create a new board"
  end

  def test_create_as_admin
    policy = BoardPolicy.new(@admin_user, Board)
    assert policy.create?, "Admin should be able to create a board"
  end

  def test_create_as_manager
    policy = BoardPolicy.new(@manager_user, Board)
    assert policy.create?, "Manager should be able to create a board"
  end

  def test_create_as_agent
    policy = BoardPolicy.new(@agent_user, Board)
    assert_not policy.create?, "Agent should not be able to create a board"
  end

  def test_update_as_admin
    policy = BoardPolicy.new(@admin_user, @board)
    assert policy.update?, "Admin should be able to update the board"
  end

  def test_update_as_manager
    policy = BoardPolicy.new(@manager_user, @board)
    assert policy.update?, "Manager should be able to update the board"
  end

  def test_update_as_agent
    policy = BoardPolicy.new(@agent_user, @board)
    assert_not policy.update?, "Agent should not be able to update the board"
  end

  def test_destroy_as_admin
    policy = BoardPolicy.new(@admin_user, @board)
    assert policy.destroy?, "Admin should be able to destroy the board"
  end

  def test_destroy_as_manager
    policy = BoardPolicy.new(@manager_user, @board)
    assert_not policy.destroy?, "Manager should not be able to destroy the board"
  end

  def test_destroy_as_agent
    policy = BoardPolicy.new(@agent_user, @board)
    assert_not policy.destroy?, "Agent should not be able to destroy the board"
  end

  def test_scope_as_admin
    scope = Pundit.policy_scope(@admin_user, Board)
    assert_equal Board.all, scope, "Admin should see all boards"
  end

  def test_scope_as_manager_with_access
    @manager_user.teams << @board.team
    scope = Pundit.policy_scope(@manager_user, Board)
    assert_includes scope, @board, "Manager should see boards for teams they are part of"
  end

  def test_scope_as_agent_with_access
    @agent_user.teams << @board.team
    scope = Pundit.policy_scope(@agent_user, Board)
    assert_includes scope, @board, "Agent should see boards for teams they are part of"
  end

  def test_scope_as_agent_without_access
    scope = Pundit.policy_scope(@agent_user, Board)
    assert_not_includes scope, @managerBoard, "Agent should not see boards for teams they are not part of"
  end
end
