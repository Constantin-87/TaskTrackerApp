# config/routes.rb
Rails.application.routes.draw do

  # Devise routes for user authentication
  devise_for :users

  # Root paths inside the devise_scope
  devise_scope :user do
    # Root path for authenticated users, redirects to the home page
    authenticated :user do
      root to: 'home_page#index', as: :authenticated_root
    end

    # Root path for unauthenticated users, redirects to the login page
    unauthenticated do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Admin page routes for managing users (only for admins)
  resources :admin_page, only: [:index, :new, :create, :edit, :update, :destroy]

  # Teams routes (only admins can manage teams)
  resources :teams, only: [:index, :new, :create, :edit, :update, :destroy]

  # Nested tasks routes under boards
  resources :boards do
    resources :tasks_page, only: [:new, :create, :edit, :update, :destroy]
  end

  # Home page route (accessible to all logged-in users)
  resources :home_page, only: [:index]

  # A catch-all route to send unhandled requests to the root path
  match '*path', to: redirect('/'), via: :all
end
