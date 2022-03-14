# frozen_string_literal: true

class UffizziCore::Deployment::CreateJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{id} CreateJob")

    deployment = UffizziCore::Deployment.find(id)

    UffizziCore::ControllerService.create_deployment(deployment)

    UffizziCore::Deployment::CreateCredentialsJob.perform_async(deployment.id)
  end
end
