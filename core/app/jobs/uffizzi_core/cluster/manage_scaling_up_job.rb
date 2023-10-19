# frozen_string_literal: true

class UffizziCore::Cluster::ManageScalingUpJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :clusters, retry: Settings.default_job_retry_count

  def perform(id, try = 1)
    cluster = UffizziCore::Cluster.find(id)

    UffizziCore::ClusterService.manage_scale_up(cluster, try)
  end
end
