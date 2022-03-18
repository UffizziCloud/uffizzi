# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::ApplicationController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController
  def resource_container
    @resource_container ||= resource_deployment.active_containers.find(params[:container_id])
  end
end
