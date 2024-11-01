require "test_helper"

class Api::TeamsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @team = teams(:agentTeam) # Assuming you have a team fixture named :agentTeam
  end

  # Test index action for an admin user
  test "should get index as admin" do
    sign_in @admin_user
    get api_teams_path, headers: { "Content-Type": "application/json" }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array), "Expected response to be an array of teams"
  end

  # Test index action for a non-admin user
  test "should not get index as non-admin" do
    sign_in @manager_user
    get api_teams_path, headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end

  # Test create action as admin
  test "should create team as admin" do
    sign_in @admin_user
    assert_difference("Team.count", 1) do
      post api_teams_path, params: {
        team: {
          name: "New Team",
          description: "A valid team description",
          user_ids: [ users(:agent_user).id ],
          board_ids: [ boards(:adminBoard).id ]
        }
      }.to_json, headers: { "Content-Type": "application/json" }
    end
    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "Team created successfully", json_response["message"]
  end

  # Test create action for a non-admin user
  test "should not create team as non-admin" do
    sign_in @manager_user
    assert_no_difference("Team.count") do
      post api_teams_path, params: {
        team: {
          name: "Unauthorized Team",
          description: "Non-admin shouldn't create this team"
        }
      }.to_json, headers: { "Content-Type": "application/json" }
    end
    assert_response :forbidden
  end

  # Test update action as admin
  test "should update team as admin" do
    sign_in @admin_user
    patch api_team_path(@team), params: {
      team: { name: "Updated Team Name" }
    }.to_json, headers: { "Content-Type": "application/json" }
    assert_response :ok

    json_response = JSON.parse(response.body)
    assert_equal "Team was successfully updated.", json_response["message"]
    @team.reload
    assert_equal "Updated Team Name", @team.name
  end

  # Test update action for a non-admin user
  test "should not update team as non-admin" do
    sign_in @manager_user
    patch api_team_path(@team), params: {
      team: { name: "Unauthorized Update" }
    }.to_json, headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end

  # Test destroy action as admin
  test "should delete team as admin" do
    sign_in @admin_user
    assert_difference("Team.count", -1) do
      delete api_team_path(@team), headers: { "Content-Type": "application/json" }
    end
    assert_response :ok

    json_response = JSON.parse(response.body)
    assert_equal "Team deleted successfully", json_response["message"]
  end

  # Test destroy action for a non-admin user
  test "should not delete team as non-admin" do
    sign_in @manager_user
    assert_no_difference("Team.count") do
      delete api_team_path(@team), headers: { "Content-Type": "application/json" }
    end
    assert_response :forbidden
  end
end
