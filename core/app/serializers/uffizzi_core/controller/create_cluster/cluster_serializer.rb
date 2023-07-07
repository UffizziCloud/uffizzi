# frozen_string_literal: true

class UffizziCore::Controller::CreateCluster::ClusterSerializer < UffizziCore::BaseSerializer
  attributes :name, :manifest, :base_ingress_host

  def base_ingress_host
    [object.namespace, Settings.app.vcluster_managed_dns_zone].join('.')
  end
end
