require "test_helper"

class Api::BoardsControllerFunctionalTest < ActionDispatch::IntegrationTest
  setup do
    # Set up users with different roles
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)

    # Set up a team for the board association
    @team = teams(:agentTeam)

    # Ensure boards exist for testing
    @adminBoard = boards(:adminBoard)
    @managerBoard = boards(:managerBoard)
    @agentBoard = boards(:agentBoard)
  end

  # Helper method to authenticate a user
  def authenticate_user(user)
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

  # 1. Test `index` action to confirm that each role sees only permitted boards
  test "admin can see all boards, manager and agent see only their team's boards" do
    authenticate_user(@admin_user) do
      get api_boards_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      boards = JSON.parse(@response.body)["boards"]
      assert boards.count >= 3, "Admin should be able to see all boards"
    end

    authenticate_user(@manager_user) do
      get api_boards_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      boards = JSON.parse(@response.body)["boards"]
      assert boards.all? { |board| board["team_id"] == teams(:managerTeam).id }, "Manager should only see boards from their own team"
    end

    authenticate_user(@agent_user) do
      get api_boards_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      boards = JSON.parse(@response.body)["boards"]
      assert boards.all? { |board| board["team_id"] == teams(:agentTeam).id }, "Agent should only see boards from their own team"
    end
  end

  # 2. Test `show` action JSON structure for a board, ensuring all expected fields are present
  test "show action returns expected JSON structure for a board" do
    authenticate_user(@admin_user) do
      assert_not_nil @adminBoard.id, "Admin board ID should not be nil"
      get api_board_path(@adminBoard), headers: { "Content-Type": "application/json" }
      assert_response :success

      board_data = JSON.parse(@response.body)

      assert_includes board_data, "board"
      assert_includes board_data, "tasks"
      assert_includes board_data, "users"
      assert_includes board_data, "status_options"
      assert_includes board_data, "priority_options"

      assert_equal @adminBoard.id, board_data["board"]["id"], "Board ID should match the requested board"
    end
  end

  # 3. Test `index` action to ensure unauthorized access is denied without valid authentication
  test "unauthenticated access to index is forbidden" do
    get api_boards_path, headers: { "Content-Type": "application/json" }
    assert_response :unauthorized
  end

  # 4. Test `show` action to confirm that an unauthorized user cannot access a restricted board
  test "agent cannot view a board that belongs to another team" do
    authenticate_user(@agent_user) do
      # Ensure we're using a valid manager board ID
      assert_not_nil @managerBoard.id, "Manager board ID should not be nil"
      get api_board_path(@managerBoard), headers: { "Content-Type": "application/json" }
      assert_response :forbidden
    end
  end

  # 5. Ensure `show` action handles non-existent board ID gracefully
  test "show action returns 404 for non-existent board" do
    authenticate_user(@admin_user) do
      # Useing high number that’s not existent
      get api_board_path(999999), headers: { "Content-Type": "application/json" }
      assert_response :not_found
      error_message = JSON.parse(@response.body)["error"]
      assert_equal "Couldn't find Board", error_message
    end
  end
end
