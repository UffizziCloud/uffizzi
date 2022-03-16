# frozen_string_literal: true

# @resource Container

class UffizziCore::Api::Cli::V1::Projects::Deployments::ContainersController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController
  # Get a list of container services for a deployment
  #
  # @path [GET] /api/cli/v1/projects/{project_slug}/deployments/{deployment_id}/contaiers
  #
  # @parameter project_slug(required,path) [string] The project_slug for the project
  # @parameter deployment_d(required,path) [integer] The id of the deployment
  #
  # @response [Container] 200 OK
  # @response 401 Not authorized
  # @response 404 Not found
  def index
    containers = resource_deployment.containers.active

    respond_with containers
  end
end
