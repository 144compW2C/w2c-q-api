# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def index
    render json: { status: "ok", app: "w2c-problems" }
  end
end
