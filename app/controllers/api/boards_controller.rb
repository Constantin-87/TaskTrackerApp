module Api
    class BoardsController < ApplicationController
      before_action :authenticate_devise_api_token!
      after_action :verify_authorized
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def index
        @boards = policy_scope(Board)  # Use policy_scope to get the correct boards for the user
        authorize Board  # Authorize the collection of boards
        render json: { boards: @boards }
      end

      def show
        @board = Board.find(params[:id])
        @tasks = @board.tasks
        @users = User.joins(:teams).where(teams: { id: @board.team_id }) # Fetch users associated with the team
        authorize @board
        status_options = Task.statuses.keys
        priority_options = Task.priorities.keys
        render json: { board: @board, tasks: @tasks, users: @users, status_options: status_options, priority_options: priority_options }
      end

      def new
        @board = Board.new
        # Show teams based on user role
        @teams = current_devise_api_token.resource_owner.admin? ? Team.all : Team.where(id: current_devise_api_token.resource_owner.team_id)
        authorize @board
      end

      def create
        @board = Board.new(board_params)
        authorize @board
        if @board.save
          render json: { board: @board }, status: :created
        else
          # Repopulate @teams if creation fails
          @teams = current_devise_api_token.resource_owner.admin? ? Team.all : Team.where(id: current_devise_api_token.resource_owner.team_id)

          render json: { errors: @board.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @board = Board.find(params[:id])
        authorize @board
        @board.destroy
        render json: { message: "Board deleted successfully" }, status: :ok
      rescue Pundit::NotAuthorizedError
        render json: { error: "You are not authorized to delete this board." }, status: :forbidden
      end

      private

      def board_params
        params.require(:board).permit(:name, :description, :team_id)
      end

      def user_not_authorized
        render json: { error: "You are not authorized to perform this action." }, status: :forbidden
      end

      def record_not_found
        render json: { error: "Couldn't find Board" }, status: :not_found
      end
    end
end
