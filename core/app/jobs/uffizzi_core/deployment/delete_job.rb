# frozen_string_literal: true

class UffizziCore::Deployment::DeleteJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(id)
    Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{id} DeleteJob")

    UffizziCore::ControllerService.delete_deployment(id)
  end
end
