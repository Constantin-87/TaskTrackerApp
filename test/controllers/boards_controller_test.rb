# test/controllers/api/boards_controller_test.rb

require "test_helper"

class Api::BoardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @agentBoard = boards(:agentBoard)
    @managerBoard = boards(:managerBoard)
    @adminBoard = boards(:adminBoard)
  end

  # Helper method to log in users
  def log_in_as(user)
    sign_in user
  end

  # Agent Tests
  test "agent should see their own board" do
    log_in_as(@agent_user)
    get api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
    assert_response :success
  end

  test "agent should not see manager's board" do
    log_in_as(@agent_user)
    get api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end

  test "agent should not see admin's board" do
    log_in_as(@agent_user)
    get api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end

  # Manager Tests
  test "manager should see their own board" do
    log_in_as(@manager_user)
    get api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
    assert_response :success
  end

  test "manager should not see agent's board" do
    log_in_as(@manager_user)
    get api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end

  test "manager should not see admin's board" do
    log_in_as(@manager_user)
    get api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end

  # Admin Tests
  test "admin should see agent's board" do
    log_in_as(@admin_user)
    get api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
    assert_response :success
  end

  test "admin should see manager's board" do
    log_in_as(@admin_user)
    get api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
    assert_response :success
  end

  test "admin should see their own board" do
    log_in_as(@admin_user)
    get api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
    assert_response :success
  end

  # Board Creation Tests
  test "agent should not be able to create a board" do
    log_in_as(@agent_user)
    assert_no_difference("Board.count") do
      # Adjusted parameters for nesting under `board` key
      post api_boards_path, params: { board: { name: "New Board", description: "Board description", team_id: @agent_user.team_id } }, as: :json
    end
    assert_response :forbidden
  end

  test "admin should be able to create a board" do
    log_in_as(@admin_user)
    assert_difference("Board.count") do
      # Adjusted parameters for nesting under `board` key
      post api_boards_path, params: { board: { name: "New Board", description: "A valid board description", team_id: teams(:agentTeam).id } }, as: :json
    end
    assert_response :created
  end

  test "admin should not create board with invalid data" do
    log_in_as(@admin_user)
    assert_no_difference("Board.count") do
      # Adjusted parameters for nesting under `board` key
      post api_boards_path, params: { board: { name: "", description: "", team_id: nil } }, as: :json
    end
    assert_response :unprocessable_entity
  end

  # Deletion Tests
  test "admin should be able to delete a board" do
    log_in_as(@admin_user)
    assert_difference("Board.count", -1) do
      delete api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
    end
    assert_response :ok
  end

  test "agent should not be able to delete a board" do
    log_in_as(@agent_user)
    assert_no_difference("Board.count") do
      delete api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
    end
    assert_response :forbidden
  end

  test "manager should not be able to delete a board" do
    log_in_as(@manager_user)
    assert_no_difference("Board.count") do
      delete api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
    end
    assert_response :forbidden
  end
end
