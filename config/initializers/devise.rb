# frozen_string_literal: true

Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. You should keep this secret key to invalidate old tokens.
  # config.secret_key = 'your-unique-secret-key'

  # Mailer sender address for sending Devise emails.
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # Load and configure the ORM. Supports :active_record (default).
  require 'devise/orm/active_record'

  # Configure case-insensitive and whitespace stripping for email addresses.
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # API-related adjustments:
  # Skip session storage for http-authentication since it’s API-only.
  config.skip_session_storage = [:http_auth]

  # Set http_authenticatable to true to support HTTP authentication (token-based or otherwise).
  config.http_authenticatable = true

   # Set the Devise navigational formats to only JSON (remove HTML responses)
   config.navigational_formats = [:json]

  # If you plan to use JWT tokens for Devise authentication, you can configure this here.
  config.jwt do |jwt|
    jwt.secret = Rails.application.secret_key_base
    jwt.dispatch_requests = [
      ['POST', %r{^/users/sign_in$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/users/sign_out$}]
    ]
    jwt.expiration_time = 30.minutes.to_i

  end



  # # Configure Warden for JWT authentication
  # config.warden do |manager|
  #   manager.strategies.add(:jwt, Warden::JWTAuth::Strategy)
  #   manager.default_strategies(scope: :user).unshift :jwt
  # end



  # Config for password length, timeouts, etc. You can adjust as needed.
  config.password_length = 6..128

  # CSRF protection is not typically required for API-only apps unless you explicitly want to support CSRF for specific endpoints.
  # config.clean_up_csrf_token_on_authentication = true
end
