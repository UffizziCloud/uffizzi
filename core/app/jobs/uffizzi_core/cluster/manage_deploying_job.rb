# frozen_string_literal: true

class UffizziCore::Cluster::ManageDeployingJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(id, try = 1)
    cluster = UffizziCore::Cluster.find(id)

    UffizziCore::ClusterService.manage_deploying(cluster, try)
  end
end
