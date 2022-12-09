# frozen_string_literal: true

class UffizziCore::Deployment::ManageDeployActivityItemJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: Settings.default_job_retry_count

  sidekiq_retry_in do |count, exception|
    case exception
    when UffizziCore::Deployment::ImagePullError
      Rails.logger.info("DEPLOYMENT_PROCESS ManageDeployActivityItemJob retry deployment_id=#{exception.deployment_id} count=#{count}")
      Settings.controller.resource_create_retry_time
    when ActiveRecord::RecordNotFound
      :kill if exception.model.constantize == UffizziCore::ActivityItem
    else
      if count == Settings.default_job_retry_count
        Sentry.capture_exception(exception)
        :kill
      else
        Settings.controller.resource_create_retry_time
      end
    end
  end

  sidekiq_retries_exhausted do |msg, exception|
    case exception
    when UffizziCore::Deployment::ImagePullError
      Rails.logger.info("DEPLOYMENT_PROCESS ManageDeployActivityItemJob exhausted #{msg.inspect} #{exception.inspect}")

      activity_item_id = msg['args'].first
      activity_item = UffizziCore::ActivityItem.find(activity_item_id)
      UffizziCore::ActivityItemService.fail_deployment!(activity_item)
    end
  end

  def perform(activity_item_id)
    activity_item = UffizziCore::ActivityItem.find(activity_item_id)
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
