class ApplicationController < ActionController::API
  def authenticate_request!
    header = request.headers['Authorization']
    header = header.split(' ').last if header.present?
    decoded = JsonWebToken.decode(header)

    if decoded && User.exists?(id: decoded[:user_id])
      @current_user = User.find(decoded[:user_id])
    else
      render json: { error: '認証エラー' }, status: :unauthorized
    end
  end
end
