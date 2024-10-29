require_relative "boot"
require "rails/all"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TaskTrackerApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # If you want to use Devise in API-only mode with token-based auth,
    # make sure to keep session management in place
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
  end
end
