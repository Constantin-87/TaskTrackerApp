class TasksPageController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_authorized

    def new
      @board = Board.find(params[:board_id])  # Find the board using the board_id parameter
      @task = @board.tasks.new  # Initialize a new task associated with the board
      authorize @board  # Authorize the board
      authorize @task  # Authorize the task
    end

    def create
      @board = Board.find(params[:board_id])
      @task = @board.tasks.build(task_params) # Associate the task with the board
      @task.current_user = current_user # Set the current user performing the change
      authorize @task

      # Add observer only if the task is assigned to a user
      @task.add_observer(NotificationObserver.new) if @task.user.present?

      if @task.save
        redirect_to board_path(@board), notice: "Task was successfully created."
      else
        render :new
      end
    end

    def edit
      @task = Task.find(params[:id])
      authorize @task
    end

    def update
      @task = Task.find(params[:id])
      @board = @task.board
      @task.current_user = current_user
      authorize @task

      # Add observer only if the task is assigned to a user
      @task.add_observer(NotificationObserver.new) if @task.user.present?

      if @task.update(task_params)
        # Check if the referrer URL contains "home_page"
        if request.referrer == authenticated_root_url
          redirect_to authenticated_root_path, notice: "Task was successfully updated from the homepage."
        else
          redirect_to board_path(@board), notice: "Task was successfully updated."
        end

      else
        render :edit
      end
    end

    def destroy
      @task = Task.find(params[:id])
      @board = @task.board
      @task.current_user = current_user
      authorize @task

      # Add observer only if the task is assigned to a user
      @task.add_observer(NotificationObserver.new) if @task.user.present?

      @task.destroy

      redirect_to board_path(@board), notice: "Task was successfully deleted."
    end

    private

    def task_params
      params.require(:task).permit(:title, :description, :due_date, :board_id, :user_id, :status, :priority)
    end
end
