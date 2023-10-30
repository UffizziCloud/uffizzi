# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Clusters::IngressesController <
  UffizziCore::Api::Cli::V1::Projects::Clusters::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_projects_clusters_ingresses

  def index
    hosts = UffizziCore::ControllerService.ingress_hosts(resource_cluster)
    user_hosts = UffizziCore::ClusterService.filter_user_ingress_host(resource_cluster, hosts)

    data = {
      ingresses: user_hosts,
    }

    respond_with data
  end
end
