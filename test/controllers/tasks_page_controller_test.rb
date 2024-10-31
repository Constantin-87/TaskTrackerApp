require "test_helper"

class Api::TasksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = users(:admin_user)
    @manager_user = users(:manager_user)
    @agent_user = users(:agent_user)
    @board = boards(:adminBoard)
    @task = tasks(:one) # Assuming a task fixture exists
  end

  # Test for creating a task as admin
  test "should create task as admin" do
    sign_in @admin_user
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

  # Test for creating a task as manager
  test "should create task as manager" do
    sign_in @manager_user
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

  # Unauthorized creation as agent
  test "should not create task as agent" do
    sign_in @agent_user
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

  # Test task update as admin
  test "should update task as admin" do
    sign_in @admin_user
    patch api_task_path(@task), params: {
      task: { title: "Updated Task Title" }
    }.to_json, headers: { "Content-Type": "application/json" }
    assert_response :ok
    @task.reload
    assert_equal "Updated Task Title", @task.title
  end

  # Unauthorized task update as agent
  test "should not update task as agent" do
    sign_in @agent_user
    patch api_task_path(@task), params: {
      task: { title: "Agent Update Attempt" }
    }.to_json, headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end

  # Test task deletion as admin
  test "should delete task as admin" do
    sign_in @admin_user
    assert_difference("Task.count", -1) do
      delete api_task_path(@task), headers: { "Content-Type": "application/json" }
    end
    assert_response :ok
  end

  # Unauthorized task deletion as manager
  test "should not delete task as manager" do
    sign_in @manager_user
    delete api_task_path(@task), headers: { "Content-Type": "application/json" }
    assert_response :forbidden
  end
end
