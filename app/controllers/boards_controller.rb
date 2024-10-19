class BoardsController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_authorized
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def index
      @boards = policy_scope(Board)  # Use policy_scope to get the correct boards for the user
      Rails.logger.info "Fetched boards: #{@boards.pluck(:name)}"
      authorize Board  # Authorize the collection of boards
    end

    def show
      @board = Board.find(params[:id])
      @tasks = @board.tasks
      @users = User.joins(:teams).where(teams: { id: @board.team_id })
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
        redirect_to board_path(@board), notice: "Board was successfully created."
      else
        # Repopulate @teams if creation fails
        @teams = current_user.admin? ? Team.all : Team.where(id: current_user.team_id)

        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace("form_errors", partial: "shared/form_errors", locals: { object: @board })
          }
        end
      end
    end


    def destroy
      @board = Board.find(params[:id])
      authorize @board
      @board.destroy
      redirect_to authenticated_root_path, notice: "Board was successfully deleted."
    end

    private

    def board_params
      params.require(:board).permit(:name, :description, :team_id)
    end

    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(authenticated_root_path)
    end
end
