# config/routes.rb
Rails.application.routes.draw do
  # API routes
  namespace :api do
    devise_for :users, controllers: { tokens: "devise/api/tokens" }
    resources :teams, only: [ :index, :show, :create, :update, :destroy ]
    resources :boards, only: [ :index, :show, :create, :destroy ]
    resources :tasks, only: [ :index, :show, :create, :update, :destroy ]  # Add :index here
    resources :notifications, only: [ :index, :update ] # For listing notifications and marking them as read
    resources :users, only: [ :index, :show, :create, :update, :destroy ]
    get "roles", to: "users#roles"
    get "home_page", to: "home_page#index" # Endpoint for fetching the homepage tasks
  end

  # Set the root path to a generic API response
  root to: proc { [ 200, {}, [ "API is live" ] ] }

   # Catch-all route for non-API routes (this will serve the React app)
   get "*path", to: "application#frontend_index", constraints: ->(req) { req.format.html? }

   # Catch-all route for undefined API routes
   match "*path", to: proc { [ 404, {}, [ "Route Not Found" ] ] }, via: :all
end
