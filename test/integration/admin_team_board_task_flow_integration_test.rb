require "test_helper"

class Api::AdminTeamBoardTaskFlowIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    # Set up an admin user for the integration test
    @admin_user = users(:admin_user)
    @admin_headers = authenticate_user(@admin_user)
  end

  # Helper method to authenticate users and set headers
  def authenticate_user(user)
    token = Devise::Api::Token.create!(
      resource_owner: user,
      access_token: SecureRandom.hex(20),
      refresh_token: SecureRandom.hex(20),
      expires_in: 3600
    )
    { "Authorization" => "Bearer #{token.access_token}", "Content-Type" => "application/json" }
  end

  test "Admin creates and manages team, board, and tasks for agent" do
    # Step 1: Admin creates a new team
    team_params = { team: { name: "Test Team", description: "Team for integration test" } }
    post api_teams_path, params: team_params.to_json, headers: @admin_headers
    assert_response :created
    team_response = JSON.parse(@response.body)
    assert team_response["team"], "Expected 'team' key in response JSON"
    team_id = team_response["team"]["id"]

    # Step 2: Admin creates a new agent user and assigns them to the team
    post "/api/users.json",
      params: {
        user: {
          first_name: "Agent",
          last_name: "User",
          email: "agent_user_integration_test@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "agent"
        }
      }.to_json,
      headers: @admin_headers
    assert_response :created
    user_response = JSON.parse(@response.body)
    assert user_response["user"], "Expected 'user' key in response JSON"
    agent_user_id = user_response["user"]["id"]




    # Step 3: Assign the agent user to the created team
    patch api_team_path(team_id), params: { team: { user_ids: [ agent_user_id ] } }.to_json, headers: @admin_headers
    assert_response :ok

    # Directly retrieve the team object after the update to check assigned users
    team = Team.find(team_id)

    # Extract assigned user IDs
    assigned_user_ids = team.users.pluck(:id)

    # Debugging output
    puts "Assigned user IDs after update: #{assigned_user_ids.inspect}"

    # Test assertion to verify that the agent user is included
    assert_includes assigned_user_ids, agent_user_id, "Agent user should be assigned to the team"





    # Step 4: Admin creates a new board and assigns the created team to it
    board_params = { board: { name: "Test Board", description: "Board for integration test", team_id: team_id } }
    post api_boards_path, params: board_params.to_json, headers: @admin_headers
    assert_response :created
    board_response = JSON.parse(@response.body)
    assert board_response["board"], "Expected 'board' key in response JSON"
    board_id = board_response["board"]["id"]

    # Step 5: Admin creates a new task on the board
    task_params = {
      task: {
        title: "Integration Test Task",
        description: "Task for agent user",
        due_date: Date.today + 7.days,
        board_id: board_id,
        status: "in_progress",
        priority: "medium"
      }
    }
    post api_tasks_path, params: task_params.to_json, headers: @admin_headers
    assert_response :created
    task_response = JSON.parse(@response.body)
    assert task_response["task"], "Expected 'task' key in response JSON"
    task_id = task_response["task"]["id"]

    # Step 6: Admin assigns the task to the agent user
    patch api_task_path(task_id), params: { task: { user_id: agent_user_id } }.to_json, headers: @admin_headers
    assert_response :ok
    task_update_response = JSON.parse(@response.body)
    assert task_update_response["task"], "Expected 'task' key in response JSON after assignment"
    assigned_task_user_id = task_update_response["task"]["user_id"]
    assert_equal agent_user_id, assigned_task_user_id, "Task should be assigned to the agent user"

    # Step 7: Authenticate as the agent user to verify task visibility
    agent_headers = authenticate_user(User.find(agent_user_id))
    get api_tasks_path, headers: agent_headers
    assert_response :success
    tasks_response = JSON.parse(@response.body)
    assert tasks_response["tasks"], "Expected 'tasks' key in response JSON"
    tasks = tasks_response["tasks"]
    assert tasks.any? { |task| task["id"] == task_id }, "Agent user should see the assigned task"

    # Step 8: Clean up by deleting the agent user, the team, and the board
    delete api_user_path(agent_user_id), headers: @admin_headers
    assert_response :ok
    delete_user_response = JSON.parse(@response.body)
    assert_equal "User deleted successfully", delete_user_response["message"]

    delete api_team_path(team_id), headers: @admin_headers
    assert_response :ok
    delete_team_response = JSON.parse(@response.body)
    assert_equal "Team deleted successfully", delete_team_response["message"]

    delete api_board_path(board_id), headers: @admin_headers
    assert_response :ok
    delete_board_response = JSON.parse(@response.body)
    assert_equal "Board deleted successfully", delete_board_response["message"]
  end
end
