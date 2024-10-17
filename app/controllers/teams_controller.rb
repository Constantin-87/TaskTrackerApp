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
      if @team.update(team_params)
        format.html { redirect_to teams_path, notice: "Team was successfully updated." }
        format.turbo_stream { redirect_to teams_path, notice: "Team was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("form_errors", partial: "shared/form_errors", locals: { object: @team }), status: :unprocessable_entity }
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
end
