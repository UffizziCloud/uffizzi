# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::ApplicationController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  def resource_deployment
    @resource_deployment ||= resource_project.deployments.active.find(params[:deployment_id])
  end
end
