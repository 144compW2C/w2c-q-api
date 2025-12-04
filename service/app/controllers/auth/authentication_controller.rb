class Auth::AuthenticationController < ApplicationController
  # POST auth/register
  def register
    user = User.new(user_params)
    if user.save
      render json: {
        name: user.name,
        email: user.email
      }, status: :created
    else
      render json: {
        error: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # POST auth/login
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, id: user.id }, status: :ok
    else
      render json: { error: 'メールアドレスまたはパスワードが違います' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :role, :class_name)
  end

end
