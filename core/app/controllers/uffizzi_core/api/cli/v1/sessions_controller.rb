# frozen_string_literal: true

# @resource Uffizzi

class UffizziCore::Api::Cli::V1::SessionsController < UffizziCore::Api::Cli::V1::ApplicationController
  skip_before_action :authenticate_request!, only: [:create]

  # Create session
  #
  # @path [POST] /api/cli/v1/session
  #
  # @parameter user(required,body)   [object<email: string, password: string >]
  # @response [object<user: object<accounts: Array<object<id: integer, state: string>> >>] 201 Created successfully
  # @response [object<errors: object<password: string >>] 422 Unprocessable entity
  def create
    session_form = UffizziCore::Api::Cli::V1::SessionCreateForm.new(session_params)

    if session_form.valid?
      sign_in(session_form.user)

      return respond_with session_form.user
    end

    respond_with session_form
  end

  # Destroy session
  #
  # @path [DELETE] /api/cli/v1/session
  #
  # @response 204 No Content
  def destroy
    sign_out

    head :no_content
  end

  private

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
