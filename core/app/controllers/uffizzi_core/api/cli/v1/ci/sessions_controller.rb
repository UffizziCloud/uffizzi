# frozen_string_literal: true

# @resource Uffizzi

class UffizziCore::Api::Cli::V1::Ci::SessionsController < UffizziCore::Api::Cli::V1::Ci::ApplicationController
  skip_before_action :authenticate_request!, only: [:create]

  # Create session
  #
  # @path [POST] /api/cli/v1/github/session
  #
  # @parameter user(required,body)   [object<token: string >]
  # @response [object<account_id: string, project_slug: string>] 201 Created successfully
  # @response [object<errors: object<token: string >>] 422 Unprocessable entity
  def create
    return render json: { errors: { title: [I18n.t('session.unsupported_login_type')] } }, status: :unprocessable_entity unless ci_session

    session_data, errors = ci_session.session_data_from_ci(user_params)
    return render json: { errors: errors }, status: :unprocessable_entity if errors.present?

    sign_in(session_data[:user])

    data = {
      account_id: session_data[:account_id],
      project_slug: session_data[:project_slug],
    }

    render json: data, status: :created
  end

  private

  def user_params
    params.require(:user).permit(:token, :github_access_token)
  end
end
