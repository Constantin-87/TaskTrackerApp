require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      first_name: "John",
      last_name: "Doe",
      email: "johndoe@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :agent
    }
  end

  test "should save valid user" do
    user = User.new(@valid_attributes)
    assert user.save, "Failed to save a valid user"
  end

  test "should not save user without first name" do
    user = User.new(@valid_attributes.merge(first_name: nil))
    assert_not user.save, "Saved the user without a first name"
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "should not save user with too short first name" do
    user = User.new(@valid_attributes.merge(first_name: "J"))
    assert_not user.save, "Saved the user with a first name that's too short"
    assert_includes user.errors[:first_name], "is too short (minimum is 2 characters)"
  end

  test "should not save user without last name" do
    user = User.new(@valid_attributes.merge(last_name: nil))
    assert_not user.save, "Saved the user without a last name"
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "should not save user with too short last name" do
    user = User.new(@valid_attributes.merge(last_name: "D"))
    assert_not user.save, "Saved the user with a last name that's too short"
    assert_includes user.errors[:last_name], "is too short (minimum is 2 characters)"
  end

  test "should not save user without email" do
    user = User.new(@valid_attributes.merge(email: nil))
    assert_not user.save, "Saved the user without an email"
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should not save user with invalid email format" do
    user = User.new(@valid_attributes.merge(email: "invalid-email"))
    assert_not user.save, "Saved the user with an invalid email format"
    assert_includes user.errors[:email], "is invalid"
  end

  test "should not save user with duplicate email" do
    User.create!(@valid_attributes)  # Create an existing user
    duplicate_user = User.new(@valid_attributes.merge(email: "johndoe@example.com"))
    assert_not duplicate_user.save, "Saved a user with a duplicate email"
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should not save user without password" do
    user = User.new(@valid_attributes.merge(password: nil, password_confirmation: nil))
    assert_not user.save, "Saved the user without a password"
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should not save user with too short password" do
    user = User.new(@valid_attributes.merge(password: "12345", password_confirmation: "12345"))
    assert_not user.save, "Saved the user with a password that's too short"
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "should not save user with non-matching password confirmation" do
    user = User.new(@valid_attributes.merge(password_confirmation: "mismatch"))
    assert_not user.save, "Saved the user with non-matching password confirmation"
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "should save user without password if it's an existing record and password is not being changed" do
    user = User.create!(@valid_attributes)
    user.password = nil
    user.password_confirmation = nil
    assert user.save, "Failed to save user without a password for an existing record"
  end
end
