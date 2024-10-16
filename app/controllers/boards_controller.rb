class BoardsController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_authorized
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
    def index
      @boards = if current_user.admin?
              Board.all  # Admin can see all boards
            elsif current_user.manager?
              Board.where(team_id: current_user.team_id)  # Manager sees only their team’s boards
            else
              Board.joins(:team).where(teams: { id: current_user.team_id })  # Agent sees boards of their team
            end
      authorize Board
    end
  
    def show
      @board = Board.find(params[:id])
      @tasks = @board.tasks
      @users = User.joins(:team).where(teams: { id: @board.team_id })
      authorize @board
    end
  
    def new
      @board = Board.new
      # Show teams based on user role
      @teams = current_user.admin? ? Team.all : Team.where(id: current_user.team_id)
      authorize @board
    end
  
    def create
      @board = Board.new(board_params)
      authorize @board
      if @board.save
        redirect_to board_path(@board), notice: 'Board was successfully created.'
      else
         # Repopulate @teams if creation fails
         @teams = current_user.admin? ? Team.all : Team.where(id: current_user.team_id)
      render :new
      end
    end

    def destroy
      @board = Board.find(params[:id])
      authorize @board
      @board.destroy
      redirect_to authenticated_root_path, notice: 'Board was successfully deleted.'
    end
  
    private
  
    def board_params
      params.require(:board).permit(:name, :team_id)
    end
  
    def user_not_authorized
      flash[:alert] = 'You are not authorized to perform this action.'
      redirect_to(authenticated_root_path)
    end
  end
  