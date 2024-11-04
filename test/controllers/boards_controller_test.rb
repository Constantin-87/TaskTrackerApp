# test/controllers/api/boards_controller_test.rb
require "test_helper"

class Api::BoardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @agentBoard = boards(:agentBoard)
    @managerBoard = boards(:managerBoard)
    @adminBoard = boards(:adminBoard)
  end

  # Helper method to mock authentication
  def mock_authenticate_user(user)
    token = Devise::Api::Token.new(
      resource_owner: user,
      access_token: SecureRandom.hex(20),
      refresh_token: SecureRandom.hex(20),
      expires_in: 3600
    )

    Api::BoardsController.any_instance.stubs(:authenticate_devise_api_token!).returns(true)
    Api::BoardsController.any_instance.stubs(:current_devise_api_token).returns(token)
    yield
  end

  # Agent Tests
  test "agent should see their own board" do
    mock_authenticate_user(@agent_user) do
      get api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
      assert_response :success
    end
  end

  test "agent should not see manager's board" do
    mock_authenticate_user(@agent_user) do
      get api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
      assert_response :forbidden
    end
  end

  test "agent should not see admin's board" do
    mock_authenticate_user(@agent_user) do
      get api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
      assert_response :forbidden
    end
  end

  # Manager Tests
  test "manager should see their own board" do
    mock_authenticate_user(@manager_user) do
      get api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
      assert_response :success
    end
  end

  test "manager should not see agent's board" do
    mock_authenticate_user(@manager_user) do
      get api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
      assert_response :forbidden
    end
  end

  test "manager should not see admin's board" do
    mock_authenticate_user(@manager_user) do
      get api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
      assert_response :forbidden
    end
  end

  # Admin Tests
  test "admin should see agent's board" do
    mock_authenticate_user(@admin_user) do
      get api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
      assert_response :success
    end
  end

  test "admin should see manager's board" do
    mock_authenticate_user(@admin_user) do
      get api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
      assert_response :success
    end
  end

  test "admin should see their own board" do
    mock_authenticate_user(@admin_user) do
      get api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
      assert_response :success
    end
  end

  # Board Creation Tests
  test "agent should not be able to create a board" do
    mock_authenticate_user(@agent_user) do
      assert_no_difference("Board.count") do
        post api_boards_path, params: { board: { name: "New Board", description: "Board description", team_id: @agent_user.team_id } }, as: :json
      end
      assert_response :forbidden
    end
  end

  test "admin should be able to create a board" do
    mock_authenticate_user(@admin_user) do
      assert_difference("Board.count") do
        post api_boards_path, params: { board: { name: "New Board", description: "A valid board description", team_id: teams(:agentTeam).id } }, as: :json
      end
      assert_response :created
    end
  end

  test "admin should not create board with invalid data" do
    mock_authenticate_user(@admin_user) do
      assert_no_difference("Board.count") do
        post api_boards_path, params: { board: { name: "", description: "", team_id: nil } }, as: :json
      end
      assert_response :unprocessable_entity
    end
  end

  # Deletion Tests
  test "admin should be able to delete a board" do
    mock_authenticate_user(@admin_user) do
      assert_difference("Board.count", -1) do
        delete api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
      end
      assert_response :ok
    end
  end

  test "agent should not be able to delete a board" do
    mock_authenticate_user(@agent_user) do
      assert_no_difference("Board.count") do
        delete api_board_path(@agentBoard), headers: { "Content-Type": "application/json" }
      end
      assert_response :forbidden
    end
  end

  test "manager should not be able to delete a board" do
    mock_authenticate_user(@manager_user) do
      assert_no_difference("Board.count") do
        delete api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
      end
      assert_response :forbidden
    end
  end
end
