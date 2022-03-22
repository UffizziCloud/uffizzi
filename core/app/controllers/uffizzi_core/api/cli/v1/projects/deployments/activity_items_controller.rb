# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::ActivityItemsController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController
  # Get the compose file for the project
  #
  # @path [GET] /api/cli/v1/projects/{project_slug}/compose_file
  #
  # @parameter project_slug(required,path) [string] The project_slug for the project
  # @parameter deployment_d(required,path) [integer] The id of the deployment
  #
  # @response [ActivtyItem] 200 OK
  # @response 401 Not authorized
  # @response 404 Not found
  def index
    activity_items = resource_deployment
      .activity_items
      .page(page)
      .per(per_page)
      .order(updated_at: :desc)
      .ransack(q_param)
      .result

    meta = meta(activity_items)
    activity_items = activity_items.map { |activity_item| ActivityItemSerializer.new(activity_item).as_json }

    render json: {
      activity_items: activity_items,
      meta: meta,
    }
  end
end
