# test/models/task_test.rb

require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @board = boards(:adminBoard)
    @user = users(:admin_user)

    @valid_attributes = {
      title: "Test Task",
      description: "This is a test task description.",
      due_date: Date.today + 7.days,
      board: @board,
      user: @user,
      status: :not_started,
      priority: :medium
    }
  end

  test "should save valid task" do
    task = Task.new(@valid_attributes)
    assert task.save, "Failed to save a valid task"
  end

  test "should not save task without title" do
    task = Task.new(@valid_attributes.merge(title: nil))
    assert_not task.save, "Saved the task without a title"
    assert_includes task.errors[:title], "can't be blank"
  end

  test "should not save task without description" do
    task = Task.new(@valid_attributes.merge(description: nil))
    assert_not task.save, "Saved the task without a description"
    assert_includes task.errors[:description], "can't be blank"
  end

  test "should not save task without board" do
    task = Task.new(@valid_attributes.merge(board: nil))
    assert_not task.save, "Saved the task without a board"
    assert_includes task.errors[:board], "must exist"
  end

  test "should allow task without user" do
    task = Task.new(@valid_attributes.merge(user: nil))
    assert task.save, "Failed to save a task without a user"
  end

  test "should default status to not_started" do
    task = Task.new(@valid_attributes.except(:status))
    assert_equal "not_started", task.status, "Status did not default to not_started"
  end

  test "should default priority to medium" do
    task = Task.new(@valid_attributes.except(:priority))
    assert_equal "medium", task.priority, "Priority did not default to medium"
  end

  test "should change status to in_progress" do
    task = Task.new(@valid_attributes)
    task.status = :in_progress
    assert_equal "in_progress", task.status
  end

  test "should change priority to high" do
    task = Task.new(@valid_attributes)
    task.priority = :high
    assert_equal "high", task.priority
  end

  test "should notify changes after save when not self update" do
    task = Task.new(@valid_attributes)
    task.current_user = users(:manager_user) # Different user to trigger notification

    # Add observer and save the task with an updated title
    task.add_observer(NotificationObserver.instance)
    task.title = "Updated Title"
    
    assert_difference "Notification.count", 1 do
      task.save
    end
  end

  test "should not notify changes after save when self update" do
    task = Task.new(@valid_attributes)
    task.current_user = @user # Same user, should prevent notification

    task.add_observer(NotificationObserver.instance)
    task.title = "Updated Title"
    
    assert_no_difference "Notification.count" do
      task.save
    end
  end

  test "should notify deletion when not self update" do
    task = Task.create!(@valid_attributes)
    task.current_user = users(:manager_user)

    task.add_observer(NotificationObserver.instance)
    
    assert_difference "Notification.count", 1 do
      task.destroy
    end
  end

  test "should not notify deletion when self update" do
    task = Task.create!(@valid_attributes)
    task.current_user = @user # Same user, should prevent notification

    task.add_observer(NotificationObserver.instance)
    
    assert_no_difference "Notification.count" do
      task.destroy
    end
  end
end
