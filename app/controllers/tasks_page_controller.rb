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
      if @task.update(task_params)
        redirect_to board_path(@board), notice: 'Task was successfully updated.'
      else
        render :edit
      end
    end
  
    def destroy
      @task = Task.find(params[:id])
      @board = @task.board
      authorize @task
      @task.destroy
      redirect_to board_path(@board), notice: 'Task was successfully deleted.'
    end
  
    private
  
    def task_params
      params.require(:task).permit(:title, :description, :due_date, :board_id)
    end
  end
  