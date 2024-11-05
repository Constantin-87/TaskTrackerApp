require "test_helper"

class TeamTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      name: "Test Team",
      description: "This is a test team description."
    }
  end

  test "should save valid team" do
    team = Team.new(@valid_attributes)
    assert team.save, "Failed to save a valid team"
  end

  test "should not save team without name" do
    team = Team.new(@valid_attributes.merge(name: nil))
    assert_not team.save, "Saved the team without a name"
    assert_includes team.errors[:name], "can't be blank"
  end

  test "should not save team with too short name" do
    team = Team.new(@valid_attributes.merge(name: "T")) # Updated to match minimum of 2 characters
    assert_not team.save, "Saved the team with a name that's too short"
    assert_includes team.errors[:name], "is too short (minimum is 2 characters)"
  end

  test "should not save team without description" do
    team = Team.new(@valid_attributes.merge(description: nil))
    assert_not team.save, "Saved the team without a description"
    assert_includes team.errors[:description], "can't be blank"
  end

  test "should not save team with too short description" do
    team = Team.new(@valid_attributes.merge(description: "Too short")) # Updated to be shorter than 20 characters
    assert_not team.save, "Saved the team with a description that's too short"
    assert_includes team.errors[:description], "is too short (minimum is 20 characters)"
  end

  test "should not save team with duplicate name" do
    Team.create!(@valid_attributes)
    duplicate_team = Team.new(@valid_attributes)
    assert_not duplicate_team.save, "Saved a team with a duplicate name"
    assert_includes duplicate_team.errors[:name], "has already been taken"
  end
end
