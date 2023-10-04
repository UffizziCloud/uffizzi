# frozen_string_literal: true

class UffizziCore::ClusterService
  class << self
    def start_deploy(cluster)
      UffizziCore::Cluster::DeployJob.perform_async(cluster.id)
    end

    def deploy_cluster(cluster)
      begin
        UffizziCore::ControllerService.create_namespace(cluster)
      rescue UffizziCore::ControllerClient::ConnectionError
        return cluster.fail_deploy_namespace!
      end

      cluster.start_deploying!

      begin
        UffizziCore::ControllerService.create_cluster(cluster)
      rescue UffizziCore::ControllerClient::ConnectionError
        return cluster.fail!
      end

      UffizziCore::Cluster::ManageDeployingJob.perform_in(5.seconds, cluster.id)
    end

    def scale_up!(cluster)
      UffizziCore::ControllerService.patch_cluster(cluster, sleep: false)
      return cluster.scale_up! unless asleep?(cluster)

      raise UffizziCore::ClusterScaleError, 'scale up'
    end

    def scale_down!(cluster)
      UffizziCore::ControllerService.patch_cluster(cluster, sleep: true)
      return cluster.scale_down! if asleep?(cluster)

      raise UffizziCore::ClusterScaleError, 'scale down'
    end

    def manage_deploying(cluster, try)
      return if cluster.disabled?
      return cluster.fail! if try > Settings.vcluster.max_creation_retry_count

      deployed_cluster = UffizziCore::ControllerService.show_cluster(cluster)

      if deployed_cluster.status.ready && deployed_cluster.status.kube_config.present?
        cluster.finish_deploy
        cluster.kubeconfig = deployed_cluster.status.kube_config
        cluster.host = deployed_cluster.status.host
        cluster.save!

        return
      end

      UffizziCore::Cluster::ManageDeployingJob.perform_in(5.seconds, cluster.id, ++try)
    end

    private

    def asleep?(cluster)
      data = UffizziCore::ControllerService.show_cluster(cluster)

      data.status.sleep
    end
  end
end
