module Api
  class TeamsController < ApplicationController
    before_action :authenticate_devise_api_token!
    before_action :authorize_admin # Ensures only admins can access

    def index
      @teams = Team.all
      authorize Team
      render json: @teams.as_json(include: { users: { only: [ :id, :first_name, :last_name ] }, boards: { only: [ :id, :name ] } }, methods: [ :users_count, :boards_count ])
    end

    def show
      team = Team.find(params[:id])
      render json: team.as_json(include: { users: { only: [ :id, :first_name, :last_name ] }, boards: { only: [ :id, :name ] } })
    end

    def create
      @team = Team.new(team_params)
      authorize @team

        if @team.save
          # Process user_ids and board_ids correctly
          user_ids = process_ids(team_params[:user_ids])
          board_ids = process_ids(team_params[:board_ids])

          # Assign users and boards
          @team.users = User.where(id: user_ids)
          @team.boards = Board.where(id: board_ids)

          render json: { message: "Team created successfully", team: @team }, status: :created
        else
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def edit
      @team = Team.find(params[:id])
      authorize @team
    end

    def update
      @team = Team.find(params[:id])
      authorize @team

      begin
        if @team.update(team_params)
          # Process user_ids and board_ids correctly
          user_ids = process_ids(team_params[:user_ids])
          board_ids = process_ids(team_params[:board_ids])

          # Assign users and boards
          @team.users = User.where(id: user_ids)
          @team.boards = Board.where(id: board_ids)

          render json: { message: "Team was successfully updated.", team: @team }, status: :ok
        else
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "An error occurred while updating team #{@team.id}: #{e.message}"
        render json: { error: "An error occurred while updating the team." }, status: :unprocessable_entity
      end
    end


    def destroy
      @team = Team.find(params[:id])
      authorize @team
      @team.destroy
      render json: { message: "Team deleted successfully" }, status: :ok
    end

    private

    def team_params
      params.require(:team).permit(:name, :description, user_ids: [], board_ids: [])
    end

    def authorize_admin
      render json: { error: "Not authorized" }, status: :forbidden unless current_devise_api_token.resource_owner&.admin?
    end

    # Helper method to process IDs
    def process_ids(ids)
      return [] if ids.nil?

      ids.reject(&:blank?).map(&:to_i)
    end
  end
end
