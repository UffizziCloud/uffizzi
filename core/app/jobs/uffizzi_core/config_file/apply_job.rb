# frozen_string_literal: true

class UffizziCore::ConfigFile::ApplyJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :config_files, retry: Settings.controller.resource_create_retry_count

  sidekiq_retry_in do |count, exception|
    case exception
    when UffizziCore::ControllerService::DeploymentNotFoundError
      Rails.logger.info("DEPLOYMENT_PROCESS ApplyJob retry deployment_id=#{exception.deployment_id} count=#{count}")
      Settings.controller.resource_create_retry_time
    end
  end

  def perform(deployment_id, config_file_id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment_id} Apply ConfigFile(config_file_id:#{config_file_id})")

    deployment = UffizziCore::Deployment.find(deployment_id)
    config_file = UffizziCore::ConfigFile.find(config_file_id)
    if deployment.disabled?
      Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment.id} deployment was disabled stop config file applying")
      return
    end

    unless UffizziCore::ControllerService.deployment_exists?(deployment)
      raise UffizziCore::ControllerService::DeploymentNotFoundError,
            deployment_id
    end

    UffizziCore::ControllerService.apply_config_file(deployment, config_file)
  end
end
