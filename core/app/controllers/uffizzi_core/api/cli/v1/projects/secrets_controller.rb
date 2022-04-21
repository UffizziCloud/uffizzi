# frozen_string_literal: true

# @resource Project/Secrets
class UffizziCore::Api::Cli::V1::Projects::SecretsController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_projects_secrets

  # Get secrets for the project
  #
  # @path [GET] /api/cli/v1/projects/{project_slug}/secrets
  # @parameter project_slug(required,path) [string]
  # @response [object<secrets: Array<object<name: string, created_at: date, updated_at: date>>>] 200 OK
  # @response 401 Not authorized
  def index
    respond_with resource_project.secrets, root: :secrets
  end

  # Add secret to project
  #
  # @path [POST] /api/cli/v1/projects/{project_slug}/secrets/bulk_create
  # @parameter project_slug(required,path) [string]
  # @parameter secrets(required,body) [object<secrets: Array<object <name: string, value: string>>>]
  # @response [object<secrets: Array<object<name: string, created_at: date, updated_at: date>>>] 201 Created
  # @response 422 A compose file already exists for this project
  # @response 401 Not authorized
  def bulk_create
    secrets_form = UffizziCore::Api::Cli::V1::Secret::BulkAssignForm.new
    secrets_form.secrets = resource_project.secrets
    secrets_form.assign_secrets(secrets_params)
    return respond_with secrets_form unless secrets_form.valid?

    resource_project.secrets.replace(secrets_form.secrets)

    UffizziCore::ProjectService.update_compose_secrets(resource_project)

    respond_with resource_project.secrets, root: :secrets
  end

  # Delete a secret from project by secret name
  #
  # @path [DELETE] /api/cli/v1/projects/{project_slug}/secrets/{secret_name}
  # @parameter project_slug(required,path) [string]
  # @response [Project] 200 OK
  # @response 404
  # @response 401 Not authorized
  def destroy
    secret_name = CGI.unescape(params[:id])
    secret = resource_project.secrets.find_by!(name: secret_name)

    UffizziCore::ProjectService.update_compose_secret_errors(resource_project, secret)

    secret.destroy

    head :no_content
  end

  private

  def secrets_params
    params.require(:secrets)
  end
end
