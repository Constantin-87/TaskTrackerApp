# File: test/controllers/tasks_controller_functional_test.rb
require "test_helper"

class Api::TasksControllerFunctionalTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @board = boards(:adminBoard)
    @task = tasks(:one)
  end

  # Helper method to authenticate a user
  def authenticate_user(user)
    token = Devise::Api::Token.new(
      resource_owner: user,
      access_token: SecureRandom.hex(20),
      refresh_token: SecureRandom.hex(20),
      expires_in: 3600
    )

    Api::TasksController.any_instance.stubs(:authenticate_devise_api_token!).returns(true)
    Api::TasksController.any_instance.stubs(:current_devise_api_token).returns(token)
    yield
  end

  # 1. Test `index` action returns tasks filtered by board_id
  test "index action returns tasks filtered by board_id" do
    authenticate_user(@admin_user) do
      get api_tasks_path(board_id: @board.id), headers: { "Content-Type": "application/json" }
      assert_response :success
      tasks = JSON.parse(@response.body)["tasks"]
      assert tasks.all? { |task| task["board_id"] == @board.id }, "All tasks should belong to the specified board"
    end
  end

  # 2. Test `index` action returns all tasks for the authenticated user when board_id is not provided
  test "index action returns all tasks for the authenticated user if board_id is not provided" do
    authenticate_user(@admin_user) do
      get api_tasks_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      tasks = JSON.parse(@response.body)["tasks"]
      assert tasks.any?, "Tasks should be present for the authenticated user"
    end
  end

  # 3. Test `show` action returns expected JSON structure for a valid task
  test "show action returns expected JSON structure for a valid task" do
    authenticate_user(@admin_user) do
      get api_task_path(@task), headers: { "Content-Type": "application/json" }
      assert_response :success
      task_data = JSON.parse(@response.body)
      assert_includes task_data, "task"
      assert_includes task_data, "status_options"
      assert_includes task_data, "priority_options"
    end
  end

  # 4. Test `show` action with an invalid task ID returns a 404 status
  test "show action returns 404 for non-existent task" do
    authenticate_user(@admin_user) do
      get api_task_path(id: 999999), headers: { "Content-Type": "application/json" }
      assert_response :not_found
      error_message = JSON.parse(@response.body)["error"]
      assert_equal "Task not found", error_message
    end
  end

  # 5. Test unauthorized access to the `index` action (without authentication)
  test "unauthenticated access to index action is forbidden" do
    get api_tasks_path, headers: { "Content-Type": "application/json" }
    assert_response :unauthorized
  end

  # 6. Test `index` action returns correct status and priority options for tasks
  test "index action returns correct status and priority options" do
    authenticate_user(@admin_user) do
      get api_tasks_path, headers: { "Content-Type": "application/json" }
      assert_response :success
      json_response = JSON.parse(@response.body)
      status_options = json_response["status_options"]
      priority_options = json_response["priority_options"]

      assert_equal Task.status_human_readable, status_options, "Status options should match the defined human-readable statuses"
      assert_equal Task.priorities.keys.map { |p| [ p, p.capitalize ] }.to_h, priority_options, "Priority options should match defined priorities"
    end
  end
end
