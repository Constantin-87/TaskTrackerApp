# app/lib/devise/token_response_decorator.rb

module Devise::Api::Responses::TokenResponseDecorator
  def body
    # Add the `role` attribute to the response body
    response_body = default_body.merge({ role: resource_owner.role, first_name: resource_owner.first_name, last_name: resource_owner.last_name })
    response_body
  end
end
