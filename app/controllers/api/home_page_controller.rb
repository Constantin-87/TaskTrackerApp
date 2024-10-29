# app/controllers/api/home_page_controller.rb
module Api
  class HomePageController < ApplicationController
    before_action :authenticate_user!

    def index
      # Fetch tasks for the logged-in user
      tasks = current_user.tasks.includes(:board)
      render json: { tasks: tasks.as_json(include: :board) }
    end
  end
end
