# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::ActivityItemsController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_projects_deployments_activity_items

  # Get the compose file for the project
  #
  # @path [GET] /api/cli/v1/projects/{project_slug}/compose_file
  #
  # @parameter project_slug(required,path) [string] The project slug
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
    activity_items = activity_items.map do |activity_item|
      UffizziCore::Api::Cli::V1::Projects::Deployments::ActivityItemSerializer.new(activity_item).as_json
    end

    render json: {
      activity_items: activity_items,
      meta: meta,
    }
  end
end
