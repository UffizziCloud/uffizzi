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
      cluster.start_scaling_up!
      UffizziCore::ControllerService.patch_cluster(cluster, sleep: false)
      UffizziCore::Cluster::ManageScalingUpJob.perform_in(5.seconds, cluster.id)
    end

    def manage_scale_up(cluster, try)
      return cluster.fail_scale_up! if try > Settings.vcluster.max_scale_up_retry_count
      return cluster.scale_up! if ready?(cluster)

      UffizziCore::Cluster::ManageScalingUpJob.perform_in(5.seconds, cluster.id, ++try)
    end

    def scale_down!(cluster)
      cluster.start_scaling_down!
      UffizziCore::ControllerService.patch_cluster(cluster, sleep: true)

      UffizziCore::Cluster::ManageScalingDownJob.perform_in(5.seconds, cluster.id)
    end

    def manage_scale_down(cluster)
      return cluster.scale_down! unless awake?(cluster)

      UffizziCore::Cluster::ManageScalingDownJob.perform_in(5.seconds, cluster.id)
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

    def filter_user_ingress_host(cluster, ingress_hosts)
      ingress_hosts.reject { |h| h == cluster.host }
    end

    private

    def awake?(cluster)
      data = UffizziCore::ControllerService.show_cluster(cluster)

      !data.status.sleep
    end

    def ready?(cluster)
      data = UffizziCore::ControllerService.show_cluster(cluster)

      data.status.ready
    end
  end
end
