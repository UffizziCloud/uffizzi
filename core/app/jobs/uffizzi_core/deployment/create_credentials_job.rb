# frozen_string_literal: true

class UffizziCore::Deployment::CreateCredentialsJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(deployment_id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment_id} CreateCredentialsJob")

    deployment = UffizziCore::Deployment.find(deployment_id)

    credentials = deployment.project.account.credentials.deployable

    credentials.each do |credential|
      UffizziCore::Deployment::CreateCredentialJob.perform_async(deployment.id, credential.id)
    end
  end
end
