module Api
  class HomePageController < ApplicationController
    before_action :authenticate_devise_api_token!

    def index
      # Fetch tasks for the logged-in user
      tasks = current_devise_api_token.resource_owner.tasks.includes(:board)
      render json: { tasks: tasks.as_json(include: :board) }
    end
  end
end
