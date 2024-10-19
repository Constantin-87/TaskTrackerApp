require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @team = teams(:agentTeam) # Assuming you have a team fixture named :agentTeam
    sign_in @admin_user
  end

  test "should get index" do
    get teams_path
    assert_response :success
  end

  test "should get new" do
    get new_team_path
    assert_response :success
  end

  test "should create team" do
    assert_difference("Team.count") do
      post teams_path, params: { team: { name: "New Team", description: "A valid team description" } }
    end
    assert_redirected_to teams_path
    assert_equal "Team was successfully created.", flash[:notice]
  end

  test "should get edit" do
    get edit_team_path(@team)
    assert_response :success
  end

  test "should update team" do
    patch team_path(@team), params: { team: { name: "Updated Team Name" } }
    assert_redirected_to teams_path
    @team.reload
    assert_equal "Updated Team Name", @team.name
    assert_equal "Team was successfully updated.", flash[:notice]
  end

  test "should destroy team" do
    assert_difference("Team.count", -1) do
      delete team_path(@team)
    end
    assert_redirected_to teams_path
    assert_equal "Team was successfully deleted.", flash[:notice]
  end
end
