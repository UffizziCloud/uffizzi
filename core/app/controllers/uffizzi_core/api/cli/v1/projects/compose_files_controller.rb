# frozen_string_literal: true

# @resource ComposeFile
class UffizziCore::Api::Cli::V1::Projects::ComposeFilesController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_projects_compose_files

  # Get the compose file for the project
  #
  # @path [GET] /api/cli/v1/projects/{project_slug}/compose_file
  #
  # @parameter project_slug(required,path) [string] The project slug
  #
  # @response [ComposeFile] 200 OK
  # @response 401 Not authorized
  # @response [object<errors: object<title: string>>] 404 Not found
  def show
    respond_with compose_file
  end

  # Create a compose file for the project
  #
  # @path [POST] /api/cli/v1/projects/{project_slug}/compose_file
  #
  # @parameter project_slug(required,path) [string] The project slug
  # @parameter params(required,body) [object <
  #    compose_file: object<path: string, source: string, content: string>,
  #    dependencies: Array<object<path: string, source: string, content: string>>>]
  #
  # @response [ComposeFile] 201 OK
  # @response 422 A compose file already exists for this project
  # @response [ComposeFile] 422 Invalid compose file
  # @response 401 Not authorized
  def create
    params = {
      project: resource_project,
      user: current_user,
      compose_file_params: compose_file_params,
      dependencies: dependencies_params[:dependencies] || [],
    }

    compose_file_form, errors = create_or_update_compose_file(params)
    return render_errors(errors) if errors.present?

    respond_with compose_file_form
  end

  # Delete the compose file for the project
  #
  # @path [DELETE] /api/cli/v1/projects/{project_slug}/compose_file
  #
  # @parameter project_slug(required,path) [string] The project slug
  #
  # @response 204 No Content
  # @response 401 Not authorized
  def destroy
    compose_file.destroy

    head :no_content
  end

  private

  def compose_file
    compose_file = resource_project.compose_file
    raise ActiveRecord::RecordNotFound if compose_file.blank?

    compose_file
  end

  def compose_file_params
    params.require(:compose_file)
  end

  def dependencies_params
    params.permit(dependencies: [:name, :path, :source, :content])
  end

  def create_or_update_compose_file(params)
    existing_compose_file = resource_project.compose_file
    if existing_compose_file.present?
      UffizziCore::Cli::ComposeFileService.update(existing_compose_file, params)
    else
      kind = UffizziCore::ComposeFile.kind.main
      UffizziCore::Cli::ComposeFileService.create(params, kind)
    end
  end

  def render_errors(errors)
    json = { errors: errors }

    render json: json, status: :unprocessable_entity
  end
end
