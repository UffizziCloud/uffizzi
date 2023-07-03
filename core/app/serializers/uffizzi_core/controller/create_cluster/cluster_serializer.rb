# frozen_string_literal: true

class UffizziCore::Controller::CreateCluster::ClusterSerializer < UffizziCore::BaseSerializer
  attributes :manifest, :base_ingress_host

  def base_ingress_host
    Settings.app.managed_dns_zone
  end
end
