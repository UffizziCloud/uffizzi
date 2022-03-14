# frozen_string_literal: true

class UffizziCore::Deployment::SendGithubPreviewMessageJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(deployment_id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment_id} SendGithubPreviewMessageJob")

    deployment = UffizziCore::Deployment.find(deployment_id)

    UffizziCore::GithubService.send_preview_message(deployment)
  end
end
