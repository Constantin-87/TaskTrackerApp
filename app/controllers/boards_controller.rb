class BoardsController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_authorized
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
    def index
      @boards = Board.all
      authorize Board
    end
  
    def show
      @board = Board.find(params[:id])
      @tasks = @board.tasks
      authorize @board
    end
  
    def new
      @board = Board.new
      authorize @board
    end
  
    def create
      @board = Board.new(board_params)
      authorize @board
      if @board.save
        redirect_to board_path(@board), notice: 'Board was successfully created.'
      else
        render :new
      end
    end
  
    private
  
    def board_params
      params.require(:board).permit(:name)
    end
  
    def user_not_authorized
      flash[:alert] = 'You are not authorized to perform this action.'
      redirect_to(root_path)
    end
  end
  