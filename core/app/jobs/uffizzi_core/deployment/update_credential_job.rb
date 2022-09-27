# frozen_string_literal: true

class UffizziCore::Deployment::UpdateCredentialJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: Settings.controller.resource_update_retry_count

  sidekiq_retry_in do |count, exception|
    case exception
    when UffizziCore::DeploymentNotFoundError
      Rails.logger.info("DEPLOYMENT_PROCESS UpdateCredentialJob retry deployment_id=#{exception.deployment_id} count=#{count}")
      Settings.controller.resource_update_retry_time
    end
  end

  def perform(deployment_id, credential_id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment_id} UpdateCredentialJob(cred_id:#{credential_id})")

    deployment = UffizziCore::Deployment.find(deployment_id)
    credential = UffizziCore::Credential.find(credential_id)

    if deployment.disabled?
      Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment.id} deployment was disabled. Stop updating credential")
      return
    end

    unless UffizziCore::ControllerService.deployment_exists?(deployment)
      raise UffizziCore::DeploymentNotFoundError,
            deployment_id
    end

    UffizziCore::ControllerService.apply_credential(deployment, credential)
  end
end
