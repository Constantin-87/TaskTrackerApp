# app/lib/devise/token_response_decorator.rb

module Devise::Api::Responses::TokenResponseDecorator
  def body
    # Add the `role` attribute to the response body
    response_body = default_body.merge({ role: resource_owner.role })
    Rails.logger.debug "TokenResponseDecorator response: #{response_body.inspect}"
    response_body
  end
end
