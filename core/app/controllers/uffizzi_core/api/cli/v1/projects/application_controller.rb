# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ApplicationController < UffizziCore::Api::Cli::V1::ApplicationController
  rescue_from Faraday::ClientError, with: :handle_container_registry_client_error

  def resource_project
    @resource_project ||= current_user.projects.find_by!(slug: params[:project_slug])
  end

  def resource_account
    @resource_account ||= resource_project.account
  end

  def policy_context
    UffizziCore::ProjectContext.new(current_user, user_access_module, resource_project, resource_account, params)
  end

  def handle_container_registry_client_error(exception)
    render json: { errors: exception.response[:body][:errors] }, status: exception.response[:status]
  end
end
