# frozen_string_literal: true

class UffizziCore::ClusterService
  class << self
    def create_empty(cluster)
      namespace = UffizziCore::ControllerService.create_namespace(cluster)
      return cluster.fail_deploy_namespace! if namespace.blank?

      UffizziCore::ControllerService.create_cluster(cluster)
    end

    def deploy_cluster(cluster)
      namespace = ControllerService.create_cluster_namespace(cluster)
      return cluster.fail_deploy_namespace! if namespace.blank?

      cluster.start_deploying!
      deployed_cluster = ControllerService.create_cluster(cluster)

      return cluster.fail! if deployed_cluster.blank?

      UffizziCore::Cluster::ManageDeployingJob.perform_in(5.seconds, cluster.id)
    end

    def manage_deploying(cluster)
      return if cluster.disabled?

      deployed_cluster = ControllerService.show_cluster(cluster)

      return deployed_cluster.finish_deploy! if deployed_cluster.ready?
      return deployed_cluster.fail! if deployed_cluster.failed?

      UffizziCore::Cluster::ManageDeployingJob.perform_in(5.seconds, cluster.id)
    end
  end
end
