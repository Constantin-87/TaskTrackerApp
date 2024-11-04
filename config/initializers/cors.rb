Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:4000", "http://127.0.0.1:4000" # Only allow the frontend

    resource "*",
      headers: :any,
      expose: [ "Authorization" ], # Allow exposing the Authorization header if needed
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
