# frozen_string_literal: true

# @resource Project/Deployment/Container/Log

class UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::LogsController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::ApplicationController
  # @path [GET] /api/cli/v1/projects/{project_slug}/deployments/{deployment_id}/containers/{container_name}/logs
  #
  # @parameter project_slug(required,path) [string] The slug of the project
  # @parameter deployment_id(required,path) [integer] The id of the deployment
  # @parameter container_name(required,path) [integer] The name of the container
  #
  # @response [object <logs: Array<object<insert_id: string, payload: string>>>] 200 OK
  # @response [object<errors: object<title: string>>] 404 Not found
  # @response 401 Not authorized
  def index
    response = UffizziCore::LogsService.fetch_container_logs(resource_container, logs_params)

    render json: response
  end

  private

  def logs_params
    params.permit(:limit)
  end
end
