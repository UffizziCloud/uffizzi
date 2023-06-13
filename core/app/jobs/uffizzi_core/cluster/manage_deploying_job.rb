# frozen_string_literal: true

class UffizziCore::Cluster::ManageDeployingJob < ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(id)
    cluster = UffizziCore::Cluster.find(id)

    UffizziCore::ClusterService.manage_deploying(cluster)
  end
end
