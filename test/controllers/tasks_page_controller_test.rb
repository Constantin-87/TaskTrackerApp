require "test_helper"

class TasksPageControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @board = boards(:adminBoard)
    @task = tasks(:one) # A pre-existing task fixture for testing
  end

  # Test for new task page as an admin
  test "should get new task as admin" do
    sign_in @admin_user
    get new_board_tasks_page_path(@board)  # Correct route helper
    assert_response :success
  end

  # Test for new task page as manager
  test "should get new task as manager" do
    sign_in @manager_user
    get new_board_tasks_page_path(@board)  # Correct route helper
    assert_response :success
  end

  # Test for new task page as agent (should be unauthorized)
  test "should not get new task as agent" do
    sign_in @agent_user
    assert_raises Pundit::NotAuthorizedError do
      get new_board_tasks_page_path(@board)  # Correct route helper
    end
  end

  # Test for task creation as admin
  test "should create task as admin" do
    sign_in @admin_user
    assert_difference("Task.count") do
      post board_tasks_page_index_path(@board), params: {  # Correct route helper for creating a task
        task: {
          title: "New Task",
          description: "Task description",
          due_date: "2024-12-01",
          board_id: @board.id,
          user_id: @admin_user.id,
          priority: "medium",
          status: "not_started"
        }
      }
    end
    assert_redirected_to board_path(@board)
    assert_equal "Task was successfully created.", flash[:notice]
  end


  # Test for task creation as manager
  test "should create task as manager" do
    sign_in @manager_user
    assert_difference("Task.count") do
      post board_tasks_page_index_path(@board), params: {  # Correct route helper for creating a task
        task: {
          title: "New Task",
          description: "Task description",
          due_date: "2024-12-01",
          board_id: @board.id,
          user_id: @manager_user.id,
          priority: "high",
          status: "in_progress"
        }
      }
    end
    assert_redirected_to board_path(@board)
    assert_equal "Task was successfully created.", flash[:notice]
  end


  # Test for task creation as agent (should be unauthorized)
  test "should not create task as agent" do
    sign_in @agent_user
    assert_raises Pundit::NotAuthorizedError do
      post board_tasks_page_index_path(@board), params: {  # Correct route helper for creating a task
        task: {
          title: "Unauthorized Task",
          description: "Task description",
          due_date: "2024-12-01",
          board_id: @board.id,
          user_id: @agent_user.id,
          priority: "low",
          status: "not_started"
        }
      }
    end
  end

  # Test task update as admin
  test "should update task as admin" do
    sign_in @admin_user
    patch board_tasks_page_path(@board, @task), params: { task: { title: "Updated Task Title" } }  # Correct route helper
    assert_redirected_to board_path(@task.board)
    @task.reload
    assert_equal "Updated Task Title", @task.title
    assert_equal "Task was successfully updated.", flash[:notice]
  end

  # Test task update as manager
  test "should update task as manager" do
    sign_in @manager_user
    patch board_tasks_page_path(@board, @task), params: { task: { title: "Manager Updated Task" } }  # Correct route helper
    assert_redirected_to board_path(@task.board)
    @task.reload
    assert_equal "Manager Updated Task", @task.title
    assert_equal "Task was successfully updated.", flash[:notice]
  end

  # Test task update as agent (should be unauthorized)
  test "should not update task as agent" do
    sign_in @agent_user
    assert_raises Pundit::NotAuthorizedError do
      patch board_tasks_page_path(@board, @task), params: { task: { title: "Agent Update Attempt" } }  # Correct route helper
    end
  end

  # Test task deletion as admin
  test "should delete task as admin" do
    sign_in @admin_user
    assert_difference("Task.count", -1) do
      delete board_tasks_page_path(@board, @task)  # Correct route helper
    end
    assert_redirected_to board_path(@task.board)
    assert_equal "Task was successfully deleted.", flash[:notice]
  end

  # Test task deletion as manager (should be unauthorized)
  test "should not delete task as manager" do
    sign_in @manager_user
    assert_raises Pundit::NotAuthorizedError do
      delete board_tasks_page_path(@board, @task)  # Correct route helper
    end
  end
end
