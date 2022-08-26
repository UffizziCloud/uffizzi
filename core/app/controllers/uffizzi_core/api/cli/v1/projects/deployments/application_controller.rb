# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  def resource_deployment
    @resource_deployment ||= resource_project.deployments.existed.find(params[:deployment_id])

    unless @resource_deployment.active?
      raise UffizziCore::DeploymentStateError, @resource_deployment.state
    end

    @resource_deployment
  end
end
