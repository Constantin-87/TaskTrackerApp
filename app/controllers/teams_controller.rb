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
    if @team.save
      redirect_to teams_path, notice: 'Team was successfully created.'
    else
      render :new
    end
  end

  def edit
    @team = Team.find(params[:id])
    authorize @team
  end

  def update
    @team = Team.find(params[:id])
    authorize @team
    if @team.update(team_params)
      redirect_to teams_path, notice: 'Team was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @team = Team.find(params[:id])
    authorize @team
    @team.destroy
    redirect_to teams_path, notice: 'Team was successfully deleted.'
  end

  private

  def team_params
    params.require(:team).permit(:name, user_ids: [], board_ids: [])
  end

  def authorize_admin
    redirect_to(root_path, alert: 'Not authorized') unless current_user.admin?
  end
end
