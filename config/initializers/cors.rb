Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "52.55.197.50" # Only allow the frontend

    resource "*",
      headers: :any,
      expose: [ "Authorization" ], # Allow exposing the Authorization header if needed
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
