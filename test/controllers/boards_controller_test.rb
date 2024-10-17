require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
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

  test "should see agent board as agent" do
    log_in_as(@agent_user)
    get board_path(@agentBoard)
    assert_response :success
  end

  test "should not see manager board as agent" do
    log_in_as(@agent_user)
    get board_path(@managerBoard)
    assert_redirected_to authenticated_root_path
  end

  test "should not see admin board as agent" do
    log_in_as(@agent_user)
    get board_path(@adminBoard)
    assert_redirected_to authenticated_root_path
  end

  test "should see manager board as manager" do
    log_in_as(@manager_user)
    get board_path(@managerBoard)
    assert_response :success
  end

  test "should not see agent board as manager" do
    log_in_as(@manager_user)
    get board_path(@agentBoard)
    assert_redirected_to authenticated_root_path
  end

  test "should not see admin board as manager" do
    log_in_as(@manager_user)
    get board_path(@adminBoard)
    assert_redirected_to authenticated_root_path
  end

  test "should see agent board as admin" do
    log_in_as(@admin_user)
    get board_path(@agentBoard)
    assert_response :success
  end

  test "should see manager board as admin" do
    log_in_as(@admin_user)
    get board_path(@managerBoard)
    assert_response :success
  end

  test "should see admin board as admin" do
    log_in_as(@admin_user)
    get board_path(@adminBoard)
    assert_response :success
  end

  test "should not get new board form as agent" do
    log_in_as(@agent_user)
    get new_board_path
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not create board as agent" do
    log_in_as(@agent_user)
    assert_no_difference("Board.count") do
      post boards_path, params: { board: { name: "New Board", description: "Board description", team_id: @agent_user.team_id } }
    end
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should not destroy board as agent" do
    log_in_as(@agent_user)
    assert_no_difference("Board.count") do
      delete board_path(@agentBoard)
    end
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should create board as admin" do
    log_in_as(@admin_user)
    assert_difference("Board.count") do
      post boards_path, params: { board: { name: "New Board", description: "Board description", team_id: teams(:agentTeam).id } }
    end
    assert_redirected_to board_path(Board.last)
    assert_equal "Board was successfully created.", flash[:notice]
  end

  test "should not create board with invalid data as admin" do
    log_in_as(@admin_user)
    assert_no_difference("Board.count") do
      post boards_path, params: { board: { name: "", description: "", team_id: nil } }
    end
    assert_response :unprocessable_entity
  end

  test "should destroy board as admin" do
    log_in_as(@admin_user)
    assert_difference("Board.count", -1) do
      delete board_path(@adminBoard)
    end
    assert_redirected_to authenticated_root_path
    assert_equal "Board was successfully deleted.", flash[:notice]
  end

  test "should not destroy board as manager" do
    log_in_as(@manager_user)
    assert_no_difference("Board.count") do
      delete board_path(@managerBoard)
    end
    assert_redirected_to authenticated_root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end
end
