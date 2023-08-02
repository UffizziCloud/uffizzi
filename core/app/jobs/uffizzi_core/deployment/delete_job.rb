# frozen_string_literal: true

class UffizziCore::Deployment::DeleteJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :disable_deployments,
                  lock: :until_executed,
                  retry: Settings.default_job_retry_count

  def perform(id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{id} DeleteJob")

    deployment = UffizziCore::Deployment.find(id)
    UffizziCore::ControllerService.delete_namespace(deployment)
  end
end
