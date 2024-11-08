# File: test/controllers/teams_controller_functional_test.rb
require "test_helper"

class Api::TeamsControllerFunctionalTest < ActionDispatch::IntegrationTest
  setup do
    # Set up different user roles and a sample team
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @team = teams(:agentTeam)
  end

  # Helper method to authenticate a user
  def authenticate_user(user)
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

  # 1. Test `index` action returns expected JSON structure
  test "index action returns JSON structure with users and boards count for each team" do
    authenticate_user(@admin_user) do
      get api_teams_path, headers: { "Content-Type" => "application/json" }
      assert_response :success
      teams = JSON.parse(@response.body)

      assert teams.is_a?(Array), "Expected response to be an array of teams"
      assert teams.all? { |team| team.key?("users_count") && team.key?("boards_count") }, "Each team should have users_count and boards_count fields"
    end
  end

  # 2. Test `show` action returns expected JSON structure for a specific team
  test "show action returns expected JSON structure for a specific team" do
    authenticate_user(@admin_user) do
      get api_team_path(@team), headers: { "Content-Type" => "application/json" }
      assert_response :success
      team_data = JSON.parse(@response.body)

      assert team_data.key?("users"), "Expected users data in team response"
      assert team_data.key?("boards"), "Expected boards data in team response"
      assert team_data["users"].is_a?(Array), "Expected users data to be an array"
      assert team_data["boards"].is_a?(Array), "Expected boards data to be an array"
    end
  end

  # 3. Test unauthorized access to the `index` action (agent user)
  test "agent cannot access index action" do
    authenticate_user(@agent_user) do
      get api_teams_path, headers: { "Content-Type" => "application/json" }
      assert_response :forbidden
    end
  end

  # 4. Test `update` action with invalid data returns error
  test "update action returns error for invalid data" do
    authenticate_user(@admin_user) do
      patch api_team_path(@team), params: {
        team: { name: "" }  # Invalid name
      }.to_json, headers: { "Content-Type" => "application/json" }

      assert_response :unprocessable_entity
      json_response = JSON.parse(@response.body)
      assert_includes json_response["errors"], "Name can't be blank"
    end
  end

  # 5. Test `destroy` action is forbidden for a manager
  test "manager cannot delete a team" do
    authenticate_user(@manager_user) do
      assert_no_difference("Team.count") do
        delete api_team_path(@team), headers: { "Content-Type" => "application/json" }
      end
      assert_response :forbidden
    end
  end

  # 6. Test unauthorized access to `show` action (agent user)
  test "agent cannot access show action for a team" do
    authenticate_user(@agent_user) do
      get api_team_path(@team), headers: { "Content-Type" => "application/json" }
      assert_response :forbidden
    end
  end
end
