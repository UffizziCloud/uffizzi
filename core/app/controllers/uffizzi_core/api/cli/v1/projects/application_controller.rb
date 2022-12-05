# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ApplicationController < UffizziCore::Api::Cli::V1::ApplicationController
  rescue_from UffizziCore::ContainerRegistryError, with: :handle_container_registry_client_error

  def resource_project
    @resource_project ||= current_user.projects.find_by!(slug: params[:project_slug])
  end

  def resource_account
    @resource_account ||= resource_project.account
  end

  def policy_context
    UffizziCore::ProjectContext.new(current_user, user_access_module, resource_project, resource_account, params)
  end

  private

  def handle_container_registry_client_error(exception)
    response_body = exception.response[:body].empty? ? {} : JSON.parse(exception.response[:body], symbolize_names: true)
    errors = if response_body.has_key?(:errors)
      convert_errors_array_to_object(response_body[:errors])
    else
      { registry_error: [I18n.t('registry.error', code: exception.response[:status])] }
    end

    render json: { errors: errors }, status: :unprocessable_entity
  end

  def convert_errors_array_to_object(array)
    array.reduce({}) { |acc, error| acc.merge(error[:code] => [error[:message], error[:detail].to_json]) }
  end
end
