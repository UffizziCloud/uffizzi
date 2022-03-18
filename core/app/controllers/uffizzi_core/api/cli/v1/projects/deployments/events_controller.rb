# frozen_string_literal: true

# @resource Event
class UffizziCore::Api::Cli::V1::Projects::Deployments::EventsController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController
  # Get the events associated with deployment
  #
  # @path [GET] /api/cli/v1/projects/{project_slug}/deployments/{deployment_id}/events
  #
  # @parameter project_slug(required,path) [string] The project_slug for the project
  # @parameter deployment_id(required,path) [integer] The id of the deployment
  #
  # @response [object<
  #   events: Array<object
  #     <count: integer, first_timestamp: string, last_timestamp: string, reason: string, message: string>
  #   > >] 200 OK
  #
  # @response 401 Not authorized
  # @response 404 Not found
  def index
    response = UffizziCore::ControllerService.fetch_deployment_events(resource_deployment)

    events = { events: response }

    render json: events
  end
end
