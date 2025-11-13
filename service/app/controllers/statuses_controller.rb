class StatusesController < ApplicationController
  def index
    statuses = Status.where(delete_flag: false).order(:id)
    render json: statuses.as_json(only: [:id, :status_name])
  end

  def show
    status = Status.find_by(id: params[:id], delete_flag: false)
    return render json: { error: 'Not Found' }, status: :not_found unless status

    render json: status.as_json(only: [:id, :status_name])
  end
end
