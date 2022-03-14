# frozen_string_literal: true

class UffizziCore::Deployment::DeleteCredentialJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(deployment_id, credential_id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment_id} DeleteCredentialJob(cred_id:#{credential_id})")

    deployment = UffizziCore::Deployment.find(deployment_id)
    credential = UffizziCore::Credential.find(credential_id)
    UffizziCore::ControllerService.delete_credential(deployment, credential)
  end
end
