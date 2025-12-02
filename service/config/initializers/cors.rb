# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # フロントのオリジンを許可
    origins 'http://localhost:5173','http://localhost:5174','http://localhost:5175','http://localhost:5176', 'http://153.126.190.250' # 必要に応じて追加

    resource '*',
              headers: :any,
              methods: [:get, :post, :put, :patch, :delete, :options, :head],
              expose: ['Authorization'],
              credentials: false
  end
end