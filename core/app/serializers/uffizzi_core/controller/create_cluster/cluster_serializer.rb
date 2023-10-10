# frozen_string_literal: true

class UffizziCore::Controller::CreateCluster::ClusterSerializer < UffizziCore::BaseSerializer
  include UffizziCore::DependencyInjectionConcern
  include_module_if_exists('UffizziCore::Controller::CreateCluster::ClusterSerializerModule')

  attributes :name, :manifest, :base_ingress_host, :distro, :image

  def base_ingress_host
    managed_dns_zone = controller_settings_service.vcluster(object).managed_dns_zone

    [object.namespace, managed_dns_zone].join('.')
  end

  def image
    kubernetes_distribution.image
  end

  def distro
    kubernetes_distribution.distro
  end

  private

  def kubernetes_distribution
    @kubernetes_distribution ||= object.kubernetes_distribution
  end
end
