# frozen_string_literal: true

class UffizziCore::Cluster::DeployJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :clusters, retry: Settings.default_job_retry_count

  def perform(id)
    cluster = UffizziCore::Cluster.find(id)

    UffizziCore::ClusterService.deploy_cluster(cluster)
  end
end
