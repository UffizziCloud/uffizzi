# frozen_string_literal: true

class UffizziCore::Credential::DockerHub::CreateWebhookJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :accounts, retry: 5

  def perform(credential_id, image, deployment_id = nil)
    if deployment_id.present?
      Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment_id} DockerHub CreateWebhooksJob")
    end

    credential = UffizziCore::Credential.find(credential_id)

    UffizziCore::DockerHubService.create_webhook(credential, image)
  end
end
