class UsersController < ApplicationController
  before_action :authenticate_request!
  before_action :authorize_admin!, only: [:update]

  def index
    users = User.where(delete_flag: false)
    render json: users.as_json(only: [:id, :name, :email, :role, :class_name])
  end

  def show
    user = User.find_by(id: params[:id], delete_flag: false)
    return render json: { error: 'Not Found' }, status: :not_found unless user
    render json: user.as_json(only: [:id, :name, :email, :role, :class_name])
  end

  def update
    user = User.find_by(id: params[:id], delete_flag: false)
    return render json: { error: 'Not Found' }, status: :not_found unless user

    user.update!(params.permit(:name, :role, :class_name, :lock_version))
    render json: user.as_json(only: [:id, :name, :email, :role, :class_name])
  rescue ActiveRecord::StaleObjectError
    render json: { error: 'Conflict: lock_version mismatch' }, status: :conflict
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def authorize_admin!
    unless @current_user&.role == 'admin'
      render json: { error: 'Forbidden: admin only' }, status: :forbidden
    end
  end
end
