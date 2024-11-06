require "test_helper"

class BoardTest < ActiveSupport::TestCase
  def setup
    # Create a team for association
    @team = Team.create(name: "Test Team", description: "A valid team description")

    # Valid attributes for a board
    @valid_attributes = {
      name: "Valid Board Name",
      description: "This is a valid description with more than 20 characters.",
      team: @team
    }
  end

  test "should save board with valid attributes" do
    board = Board.new(@valid_attributes)
    assert board.save, "Failed to save a valid board"
  end

  test "should not save board without a name" do
    board = Board.new(@valid_attributes.merge(name: ""))
    assert_not board.save, "Saved the board without a name"
    assert_includes board.errors[:name], "cannot be blank, it must be between 2 and 25 characters."
  end

  test "should not save board with a name shorter than 2 characters" do
    board = Board.new(@valid_attributes.merge(name: "A"))
    assert_not board.save, "Saved the board with a name shorter than 2 characters"
    assert_includes board.errors[:name], "must be between 2 and 25 characters."
  end

  test "should not save board with a name longer than 25 characters" do
    long_name = "A" * 26
    board = Board.new(@valid_attributes.merge(name: long_name))
    assert_not board.save, "Saved the board with a name longer than 25 characters"
    assert_includes board.errors[:name], "must be between 2 and 25 characters."
  end

  test "should not save board with a non-unique name" do
    Board.create!(@valid_attributes)
    duplicate_board = Board.new(@valid_attributes)
    assert_not duplicate_board.save, "Saved the board with a non-unique name"
    assert_includes duplicate_board.errors[:name], "must be unique, this name is already taken."
  end

  test "should not save board without a description" do
    board = Board.new(@valid_attributes.merge(description: ""))
    assert_not board.save, "Saved the board without a description"
    assert_includes board.errors[:description], "cannot be blank, it must be between 20 and 200 characters."
  end

  test "should not save board with a description shorter than 20 characters" do
    board = Board.new(@valid_attributes.merge(description: "Short description"))
    assert_not board.save, "Saved the board with a description shorter than 20 characters"
    assert_includes board.errors[:description], "must be between 20 and 300 characters."
  end

  test "should not save board with a description longer than 300 characters" do
    long_description = "A" * 301
    board = Board.new(@valid_attributes.merge(description: long_description))
    assert_not board.save, "Saved the board with a description longer than 300 characters"
    assert_includes board.errors[:description], "must be between 20 and 300 characters."
  end

  test "should not save board without a team" do
    board = Board.new(@valid_attributes.merge(team: nil))
    assert_not board.save, "Saved the board without a team"
    assert_includes board.errors[:team], "must be selected."
  end
end
