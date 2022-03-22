# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::ApplicationController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController
  def resource_container
    @resource_container ||= resource_deployment.active_containers.find_by!(name: params[:container_name])
  end
end
