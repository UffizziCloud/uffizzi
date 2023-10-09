# frozen_string_literal: true

class UffizziCore::Cluster::ManageScalingDownJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :clusters, retry: Settings.default_job_retry_count

  def perform(id)
    cluster = UffizziCore::Cluster.find(id)

    UffizziCore::ClusterService.manage_scale_down(cluster)
  end
end
