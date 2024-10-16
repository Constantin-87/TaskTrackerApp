class TasksPageController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_authorized
    
    def new
      @task = Task.new
      @task.board_id = params[:board_id]  # Preload the board_id
      authorize @task
    end
  
    def create
      @board = Board.find(params[:board_id])
      @task = @board.tasks.build(task_params) # Associate the task with the board
      authorize @task

      # Add observer only if the task is assigned to a user
      @task.add_observer(NotificationObserver.new) if @task.user.present?

      if @task.save
        redirect_to board_path(@board), notice: 'Task was successfully created.'
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
      @board = @task.board # Retrieve the associated board
      authorize @task

      # Add observer only if the task is assigned to a user
      @task.add_observer(NotificationObserver.new) if @task.user.present?

      if @task.update(task_params)
        # Check if the referrer URL contains "home_page"
        if request.referrer == authenticated_root_url
          redirect_to authenticated_root_path, notice: 'Task was successfully updated from the homepage.'
        else
          redirect_to board_path(@board), notice: 'Task was successfully updated.'
        end

      else
        render :edit
      end
    end
  
    def destroy
      @task = Task.find(params[:id])
      @board = @task.board
      authorize @task
      
      # Add observer only if the task is assigned to a user
      @task.add_observer(NotificationObserver.new) if @task.user.present?

      @task.destroy

      redirect_to board_path(@board), notice: 'Task was successfully deleted.'
    end
  
    private
  
    def task_params
      params.require(:task).permit(:title, :description, :due_date, :board_id, :user_id, :status, :priority)
    end
    
  end
  