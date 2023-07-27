# frozen_string_literal: true

class UffizziCore::Controller::CreateCluster::ClusterSerializer < UffizziCore::BaseSerializer
  include UffizziCore::DependencyInjectionConcern

  attributes :name, :manifest, :base_ingress_host

  def base_ingress_host
    managed_dns_zone = controller_settings_service.vcluster(object).managed_dns_zone

    [object.namespace, managed_dns_zone].join('.')
  end
end
