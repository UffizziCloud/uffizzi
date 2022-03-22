# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::BuildsController <
  UffizziCore::Api::Cli::V1::Projects::Deployments::Containers::ApplicationController
  def logs
    raise ActiveRecord::RecordNotFound if !resource_build

    logs = UffizziCore::BuildService.logs(resource_build)

    render json: { logs: logs }
  end

  private

  def resource_build
    @resource_build ||= resource_container.activity_items.last&.build
  end
end
