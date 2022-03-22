# frozen_string_literal: true

class UffizziCore::Deployment::ManageDeployActivityItemJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(id)
    activity_item = UffizziCore::ActivityItem.find(id)
    container = activity_item.container

    if container.disabled?
      logger_message = "DEPLOYMENT_PROCESS deployment_id=#{container.deployment_id} activity_item_id=#{activity_item.id}
      deployment was disabled stop monitoring"
      Rails.logger.info(logger_message)
      return
    end

    UffizziCore::ActivityItemService.manage_deploy_activity_item(activity_item)
  end
end
