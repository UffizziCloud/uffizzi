# frozen_string_literal: true

class UffizziCore::Deployment::DeployContainersJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: Settings.controller.resource_create_retry_count

  sidekiq_retry_in do |count, exception|
    case exception
    when UffizziCore::DeploymentNotFoundError
      Rails.logger.info("DEPLOYMENT_PROCESS DeployContainersJob retry deployment_id=#{exception.deployment_id} count=#{count}")
      Settings.controller.resource_create_retry_time
    end
  end

  def perform(id, repeated = false)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{id} DeployContainersJob")

    deployment = UffizziCore::Deployment.find(id)
    if deployment.disabled?
      Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment.id} deployment was disabled stop deploying")
      return
    end

    raise UffizziCore::DeploymentNotFoundError, id unless UffizziCore::ControllerService.deployment_exists?(deployment)

    UffizziCore::DeploymentService.deploy_containers(deployment, repeated)
  end
end
