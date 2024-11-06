require "test_helper"

class Api::TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @team = teams(:agentTeam)
  end

  # Helper method to mock authentication
  def mock_authenticate_user(user)
    token = Devise::Api::Token.new(
      resource_owner: user,
      access_token: SecureRandom.hex(20),
      refresh_token: SecureRandom.hex(20),
      expires_in: 3600
    )

    Api::TeamsController.any_instance.stubs(:authenticate_devise_api_token!).returns(true)
    Api::TeamsController.any_instance.stubs(:current_devise_api_token).returns(token)
    yield
  end


  # Test index action for an admin user
  test "should get index as admin" do
    mock_authenticate_user(@admin_user) do
      get api_teams_path, headers: { "Content-Type" => "application/json" }
      assert_response :success

      json_response = JSON.parse(response.body)
      assert json_response.is_a?(Array), "Expected response to be an array of teams"
    end
  end

  # Test index action for a non-admin user
  test "should not get index as non-admin" do
    mock_authenticate_user(@manager_user) do
      get api_teams_path, headers: { "Content-Type" => "application/json" }
      assert_response :forbidden
    end
  end

  # Test create action as admin
  test "should create team as admin" do
    mock_authenticate_user(@admin_user) do
      assert_difference("Team.count", 1) do
        post api_teams_path, params: {
          team: {
            name: "New Team",
            description: "A valid team description",
            user_ids: [ users(:agent_user).id ],
            board_ids: [ boards(:adminBoard).id ]
          }
        }.to_json, headers: { "Content-Type" => "application/json" }
      end
      assert_response :created

      json_response = JSON.parse(response.body)
      assert_equal "Team created successfully", json_response["message"]
    end
  end

  # Test create action for a non-admin user
  test "should not create team as non-admin" do
    mock_authenticate_user(@manager_user) do
      assert_no_difference("Team.count") do
        post api_teams_path, params: {
          team: {
            name: "Unauthorized Team",
            description: "Non-admin shouldn't create this team"
          }
        }.to_json, headers: { "Content-Type" => "application/json" }
      end
      assert_response :forbidden
    end
  end

  # Test update action as admin
  test "should update team as admin" do
    mock_authenticate_user(@admin_user) do
      patch api_team_path(@team), params: {
        team: { name: "Updated Team Name" }
      }.to_json, headers: { "Content-Type" => "application/json" }
      assert_response :ok

      json_response = JSON.parse(response.body)
      assert_equal "Team was successfully updated.", json_response["message"]
      @team.reload
      assert_equal "Updated Team Name", @team.name
    end
  end

  # Test update action for a non-admin user
  test "should not update team as non-admin" do
    mock_authenticate_user(@manager_user) do
      patch api_team_path(@team), params: {
        team: { name: "Unauthorized Update" }
      }.to_json, headers: { "Content-Type" => "application/json" }
      assert_response :forbidden
    end
  end

  # Test destroy action as admin
  test "should delete team as admin" do
    mock_authenticate_user(@admin_user) do
      assert_difference("Team.count", -1) do
        delete api_team_path(@team), headers: { "Content-Type" => "application/json" }
      end
      assert_response :ok

      json_response = JSON.parse(response.body)
      assert_equal "Team deleted successfully", json_response["message"]
    end
  end

  # Test destroy action for a non-admin user
  test "should not delete team as non-admin" do
    mock_authenticate_user(@manager_user) do
      assert_no_difference("Team.count") do
        delete api_team_path(@team), headers: { "Content-Type" => "application/json" }
      end
      assert_response :forbidden
    end
  end
end
