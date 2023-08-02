# frozen_string_literal: true

class UffizziCore::Cluster::DeleteJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :clusters,
                  lock: :until_executed,
                  retry: Settings.default_job_retry_count

  def perform(id)
    Rails.logger.info("DEPLOYMENT_PROCESS cluster_id=#{id} DeleteJob")

    cluster = UffizziCore::Cluster.find(id)
    UffizziCore::ControllerService.delete_namespace(cluster)
  end
end
