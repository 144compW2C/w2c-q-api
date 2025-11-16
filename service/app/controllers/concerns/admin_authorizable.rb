module AdminAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
    before_action :authorize_admin!, only: [:create, :update, :destroy, :approve, :organize]
  end

  private

  def authorize_admin!
    unless @current_user&.role == 'admin' || @current_user&.role == 'reviewer'
      render json: { error: 'Forbidden: admin only' }, status: :forbidden
    end
  end
end
