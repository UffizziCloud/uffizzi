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
    project_secrets = resource_project.secrets.present? ? resource_project.secrets : []
    secrets = project_secrets.map { |secret| { name: secret['name'] } }

    render json: { secrets: secrets }, status: :ok
  end

  # Add secret to project
  #
  # @path [POST] /api/cli/v1/projects/{project_slug}/secrets/bulk_create
  # @parameter project_slug(required,path) [string]
  # @parameter secrets(required,body) [object<secrets: Array<object <name: string, value: string>>>]
  # @response [object<secrets: Array<object<name: string>>>] 201 Created
  # @response 422 A compose file already exists for this project
  # @response 401 Not authorized
  def bulk_create
    project_form = resource_project.becomes(UffizziCore::Api::Cli::V1::Project::UpdateForm)
    project_form.assign_secrets!(secrets_params)
    return render json: { errors: project_form.errors }, status: :unprocessable_entity unless project_form.save

    UffizziCore::ProjectService.update_compose_secrets(project_form)
    secrets = project_form.secrets.map { |secret| { name: secret['name'] } }

    render json: { secrets: secrets }, status: :created
  end

  # Delete a secret from project by secret id
  #
  # @path [DELETE] /api/cli/v1/projects/{project_slug}/secrets/{id}
  # @parameter project_slug(required,path) [string]
  # @response [Project] 200 OK
  # @response 422
  # @response 401 Not authorized
  def destroy
    secret_name = CGI.unescape(params[:id])
    secret = OpenStruct.new(name: secret_name)
    project_form = resource_project.becomes(UffizziCore::Api::Cli::V1::Project::DeleteSecretForm)
    project_form.secret = secret

    if project_form.invalid?
      return respond_with project_form
    end

    project_form.delete_secret!
    if project_form.save!(validate: false)
      UffizziCore::ProjectService.update_compose_secret_errors(project_form, secret)
    end

    respond_with project_form
  end

  private

  def secrets_params
    params.require(:secrets)
  end
end
