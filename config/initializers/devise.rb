# config/initializers/devise.rb

require "devise/token_response_decorator" # Load the decorator

Devise.setup do |config|
  config.mailer_sender = "please-change-me-at-config-initializers-devise@example.com"
  require "devise/orm/active_record"

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  config.skip_session_storage = [ :http_auth ]
  config.http_authenticatable = false
  config.navigational_formats = []  # No HTML views, only API (JSON)

  config.password_length = 6..128

  config.api.configure do |api|
    # Authorization
    api.authorization.key = "Authorization"
    api.authorization.scheme = "Bearer"
    api.authorization.location = :both # :header and :params
    api.authorization.params_key = "access_token"


    # Base classes
    api.base_token_model = "Devise::Api::Token"
  end
end

Devise::Api::Responses::TokenResponse.prepend Devise::Api::Responses::TokenResponseDecorator
