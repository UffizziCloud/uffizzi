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
    @current_user ||= UffizziCore::User.find_by(id: session[:user_id])
  end

  def authenticate_request!
    current_user ? true : head(:unauthorized)
  end
end
