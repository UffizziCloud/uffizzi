# frozen_string_literal: true

module UffizziCore::AuthManagement
  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = @current_user = nil
  end

  def signed_in?
    session[:user_id].present? && current_user.present?
  end

  def current_user
    @current_user ||= UffizziCore::User.find_by(id: current_user_id)
  end

  def auth_token
    header = request.headers['Authorization']
    header&.split(' ')&.last
  end

  def current_user_id
    return session[:user_id] if session[:user_id].present?
    return unless auth_token.present?

    decoded_token = UffizziCore::TokenService.decode(auth_token)
    return unless decoded_token
    return if decoded_token.first['expires_at'] < DateTime.now

    decoded_token.first['user_id']
  end

  def authenticate_request!
    current_user ? true : head(:unauthorized)
  end
end
