# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClusterSerializer < UffizziCore::BaseSerializer
  type :cluster

  attributes :id, :name, :state, :kubeconfig, :created_at, :host, :k8s_version

  def k8s_version
    object.kubernetes_distribution&.version || UffizziCore::KubernetesDistribution.default.version
  end
end
