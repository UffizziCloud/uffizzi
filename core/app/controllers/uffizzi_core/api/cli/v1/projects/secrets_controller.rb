# frozen_string_literal: true

# @resource Project/Secrets
class UffizziCore::Api::Cli::V1::Projects::SecretsController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  # Get secrets for the project
  #
  # @path [GET] /api/cli/v1/projects/{project_slug}/secrets
  # @parameter project_slug(required,path) [string]
  # @response [object<secrets: Array<object<name: string>> >] 200 OK
  # @response 401 Not authorized
  def index
    respond_with resource_project.secrets, root: 'secrets'
  end

  # Add secret to project
  #
  # @path [POST] /api/cli/v1/projects/{project_slug}/secrets
  # @parameter project_slug(required,path) [string]
  # @parameter secrets(required,body) [Array<object <name: string, value: string>>]
  # @response [object<secrets: Array<object<name: string>>>] 201 Created
  # @response 422 A compose file already exists for this project
  # @response 401 Not authorized
  def bulk_create
    project_form = resource_project.becomes(UffizziCore::Api::Cli::V1::Project::UpdateForm)
    project_form.assign_secrets(secrets_params)

    unless project_form.save
      respond_with project_form
      return
    end

    UffizziCore::ProjectService.update_compose_secrets(project_form)

    respond_with project_form.secrets, root: 'secrets'
  end

  # Delete a secret from project by secret id
  #
  # @path [DELETE] /api/cli/v1/projects/{project_slug}/secrets/{id}
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
