class HomePageController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_authorized
  
    def index
      # Home page for all logged-in users
      authorize :home_page, :index?
    end
  end
  