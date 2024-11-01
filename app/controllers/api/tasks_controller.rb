module Api
  class TasksController < ApplicationController
    before_action :authenticate_user!

    def index
    # Use board_id from params to filter tasks for a specific board if provided
    if params[:board_id].present?
      board_id = params[:board_id]
      tasks = Task.where(board_id: board_id).includes(:board)
    else
      tasks = current_user.tasks.includes(:board)
    end

      # Use the human-readable statuses
      status_options = Task.status_human_readable
      priority_options = Task.priorities.keys.map { |priority| [ priority, priority.capitalize ] }.to_h

      render json: {
        tasks: tasks.as_json(include: :board).map do |task|
           Rails.logger.info "Task data with human labels: #{task}"
          task.merge(
            "human_status" => Task.status_human_readable[task["status"]],
            "priority" => task["priority"].to_s.capitalize
          )
        end,
        status_options: status_options,
        priority_options: priority_options
      }
    end

    # Show action to retrieve a specific task by ID for editing
    def show
      status_options = Task.status_human_readable
      priority_options = Task.priorities.keys.map { |priority| [ priority, priority.capitalize ] }.to_h

      if params[:id] == "-1"
        render json: { status_options: status_options, priority_options: priority_options }
      else
        begin
          task = Task.find(params[:id])
          render json: {
            task: task.as_json(include: :board).merge("human_status" => task.human_status),
            status_options: status_options,
            priority_options: priority_options
          }
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Task not found" }, status: :not_found
        end
      end
    end

    def create
      authorize Task
      # Ensure board_id is provided in the params
      unless params[:task][:board_id].present?
        render json: { errors: [ "Board must be selected" ] }, status: :unprocessable_entity and return
      end

      board = Board.find_by(id: params[:task][:board_id])
      if board.nil?
        render json: { errors: [ "Board not found" ] }, status: :not_found and return
      end

      task = board.tasks.build(task_params)
      task.current_user = current_user

      # Add an observer if user is present
      task.add_observer(NotificationObserver.instance) if task.user.present?

      if task.save
        NotificationObserver.instance.update("Task created", task)
        render json: { task: task }, status: :created
      else
        render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def edit
      task = Task.find(params[:id])
      render json: { task: task }
    end

    def update
      task = Task.find(params[:id])
      authorize task
      task.current_user = current_user

      if task.update(task_params)
        NotificationObserver.instance.update("Task updated", task)
        render json: { task: task }, status: :ok
      else
        Rails.logger.error "Task update failed with errors: #{task.errors.full_messages}"
        render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      task = Task.find(params[:id])
      authorize task
      NotificationObserver.instance.update("Task deleted", task)
      task.destroy
      render json: { message: "Task deleted successfully" }, status: :ok
    end

    private

    def task_params
      # Only permit parameters without reprocessing `status`
      params.require(:task).permit(:title, :description, :due_date, :board_id, :user_id, :status, :priority)
    end
  end
end
