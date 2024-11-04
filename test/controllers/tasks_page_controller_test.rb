# test/controllers/api/tasks_controller_test.rb
require "test_helper"

class Api::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @board = boards(:adminBoard)
    @task = tasks(:one) # Assuming a task fixture exists
  end

  # Helper method to mock authentication
  def mock_authenticate_user(user)
    Api::TasksController.any_instance.stubs(:authenticate_devise_api_token!).returns(true)
    Api::TasksController.any_instance.stubs(:current_user).returns(user)
    yield
  end

  # Test for creating a task as admin
  test "should create task as admin" do
    mock_authenticate_user(@admin_user) do
      assert_difference("Task.count") do
        post api_tasks_path, params: {
          task: {
            title: "New Task",
            description: "Task description",
            due_date: "2024-12-01",
            board_id: @board.id,
            user_id: @admin_user.id,
            priority: "medium",
            status: "not_started"
          }
        }.to_json, headers: { "Content-Type": "application/json" }
      end
      assert_response :created
    end
  end

  # Test for creating a task as manager
  test "should create task as manager" do
    mock_authenticate_user(@manager_user) do
      assert_difference("Task.count") do
        post api_tasks_path, params: {
          task: {
            title: "New Manager Task",
            description: "Manager task description",
            due_date: "2024-12-01",
            board_id: @board.id,
            user_id: @manager_user.id,
            priority: "high",
            status: "in_progress"
          }
        }.to_json, headers: { "Content-Type": "application/json" }
      end
      assert_response :created
    end
  end

  # Unauthorized creation as agent
  test "should not create task as agent" do
    mock_authenticate_user(@agent_user) do
      assert_no_difference("Task.count") do
        post api_tasks_path, params: {
          task: {
            title: "Unauthorized Task",
            description: "Task description",
            due_date: "2024-12-01",
            board_id: @board.id,
            user_id: @agent_user.id,
            priority: "low",
            status: "not_started"
          }
        }.to_json, headers: { "Content-Type": "application/json" }
      end
      assert_response :forbidden
    end
  end

  # Test task update as admin
  test "should update task as admin" do
    mock_authenticate_user(@admin_user) do
      patch api_task_path(@task), params: {
        task: { title: "Updated Task Title" }
      }.to_json, headers: { "Content-Type": "application/json" }
      assert_response :ok
      @task.reload
      assert_equal "Updated Task Title", @task.title
    end
  end

  # Unauthorized task update as agent
  test "should not update task as agent" do
    mock_authenticate_user(@agent_user) do
      patch api_task_path(@task), params: {
        task: { title: "Agent Update Attempt" }
      }.to_json, headers: { "Content-Type": "application/json" }
      assert_response :forbidden
    end
  end

  # Test task deletion as admin
  test "should delete task as admin" do
    mock_authenticate_user(@admin_user) do
      assert_difference("Task.count", -1) do
        delete api_task_path(@task), headers: { "Content-Type": "application/json" }
      end
      assert_response :ok
    end
  end

  # Unauthorized task deletion as manager
  test "should not delete task as manager" do
    mock_authenticate_user(@manager_user) do
      delete api_task_path(@task), headers: { "Content-Type": "application/json" }
      assert_response :forbidden
    end
  end
end
