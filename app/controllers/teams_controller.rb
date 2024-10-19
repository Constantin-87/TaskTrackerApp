class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin # Ensures only admins can access

  def index
    @teams = Team.all
    authorize Team
  end

  def new
    @team = Team.new
    authorize @team
  end

  def create
    @team = Team.new(team_params)
    authorize @team

    respond_to do |format|
      if @team.save
        # Process user_ids and board_ids correctly
        user_ids = process_ids(team_params[:user_ids])
        board_ids = process_ids(team_params[:board_ids])

        # Assign users and boards
        @team.users = User.where(id: user_ids)
        @team.boards = Board.where(id: board_ids)

        format.html { redirect_to teams_path, notice: "Team was successfully created." }
        format.turbo_stream { redirect_to teams_path, notice: "Team was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "shared/form_errors", locals: { object: @team }), status: :unprocessable_entity }
      end
    end
  end

  def edit
    @team = Team.find(params[:id])
    authorize @team
  end

  def update
    @team = Team.find(params[:id])
    authorize @team

    respond_to do |format|
      begin
        if @team.update(team_params)

          # Process user_ids and board_ids correctly
          user_ids = process_ids(team_params[:user_ids])
          board_ids = process_ids(team_params[:board_ids])

          # Assign users and boards
          @team.users = User.where(id: user_ids)
          @team.boards = Board.where(id: board_ids)

          format.html { redirect_to teams_path, notice: "Team was successfully updated." }
          format.turbo_stream { redirect_to teams_path, notice: "Team was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "shared/form_errors", locals: { object: @team }), status: :unprocessable_entity }
        end
      rescue => e
        Rails.logger.error "An error occurred while updating team #{@team.id}: #{e.message}"
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @team = Team.find(params[:id])
    authorize @team
    @team.destroy
    redirect_to teams_path, notice: "Team was successfully deleted."
  end

  private

  def team_params
    params.require(:team).permit(:name, :description, user_ids: [], board_ids: [])
  end

  def authorize_admin
    redirect_to(root_path, alert: "Not authorized") unless current_user.admin?
  end

  # Helper method to process IDs
  def process_ids(ids)
    return [] if ids.nil?

    ids.reject(&:blank?).map { |id| id.split(",") }.flatten.map(&:to_i)
  end
end
