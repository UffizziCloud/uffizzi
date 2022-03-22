# frozen_string_literal: true

class UffizziCore::Deployment::CreateWebhooksJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{id} CreateWebhooksJob")

    deployment = UffizziCore::Deployment.find(id)

    UffizziCore::DeploymentService.create_webhooks(deployment)
  end
end
