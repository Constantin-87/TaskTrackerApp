# app/models/jwt_blacklist.rb
class JwtBlacklist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = "jwt_blacklists"
  after_create do
    Rails.logger.info "Added JWT token to blacklist: #{self.jti}"  # Log addition to blacklist
  end
end
