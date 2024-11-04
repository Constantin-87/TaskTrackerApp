Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:3000", "http://127.0.0.1:3000" # Only allow the frontend

    resource "*",
      headers: :any,
      expose: [ "Authorization" ], # Allow exposing the Authorization header if needed
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
