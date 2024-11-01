module Api
    class BoardsController < ApplicationController
      before_action :authenticate_user!
      after_action :verify_authorized
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      def index
        @boards = policy_scope(Board)  # Use policy_scope to get the correct boards for the user
        authorize Board  # Authorize the collection of boards
        render json: { boards: @boards } # Return boards as JSON
      end

      def show
        @board = Board.find(params[:id])
        @tasks = @board.tasks
        @users = User.joins(:teams).where(teams: { id: @board.team_id }) # Fetch users associated with the team
        authorize @board
        status_options = Task.statuses.keys # Assuming status is an enum
        priority_options = Task.priorities.keys # Assuming priority is an enum
        render json: { board: @board, tasks: @tasks, users: @users, status_options: status_options, priority_options: priority_options }
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
          render json: { board: @board }, status: :created # Return created board as JSON
        else
          # Repopulate @teams if creation fails
          @teams = current_user.admin? ? Team.all : Team.where(id: current_user.team_id)

          render json: { errors: @board.errors.full_messages }, status: :unprocessable_entity
        end
      end


      def destroy
        Rails.logger.info("Current user: #{current_user.inspect}")
        @board = Board.find(params[:id])
        authorize @board
        @board.destroy
        render json: { message: "Board deleted successfully" }, status: :ok
      rescue Pundit::NotAuthorizedError
        Rails.logger.info("User not authorized to delete board")
        render json: { error: "You are not authorized to delete this board." }, status: :forbidden
      end

      private

      def board_params
        params.require(:board).permit(:name, :description, :team_id)
      end

      def user_not_authorized
        render json: { error: "You are not authorized to perform this action." }, status: :forbidden
      end
    end
end
