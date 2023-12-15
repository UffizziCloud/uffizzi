# frozen_string_literal: true

class UffizziCore::Controller::UpdateCluster::ClusterSerializer < UffizziCore::BaseSerializer
  include UffizziCore::DependencyInjectionConcern
  include_module_if_exists('UffizziCore::Controller::UpdateCluster::ClusterSerializerModule')

  attributes :name, :manifest, :base_ingress_host

  def base_ingress_host
    managed_dns_zone = controller_settings_service.vcluster_settings_by_vcluster(object).managed_dns_zone

    [object.namespace, managed_dns_zone].join('.')
  end
end
