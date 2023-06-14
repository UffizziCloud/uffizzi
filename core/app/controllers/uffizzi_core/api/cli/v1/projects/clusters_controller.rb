# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClustersController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  include UffizziCore::Api::Cli::V1::Projects::ClustersControllerModule

  before_action :authorize_uffizzi_core_api_cli_v1_projects_clusters
  after_action :update_show_trial_quota_exceeded_warning, only: [:create, :destroy]

  def index
    clusters = resource_project.clusters.deployed

    respond_with clusters
  end

  def create
    cluster_form = UffizziCore::Api::Cli::V1::Cluster::CreateForm.new(cluster_params)
    cluster_form.project = resource_project
    cluster_form.deployed_by = current_user
    return respond_with cluster_form unless cluster_form.save

    kubeconfig_content = UffizziCore::ClusterService.create_empty(cluster_form)

    respond_with cluster_form, serializer: UffizziCore::Api::Cli::V1::Projects::ClusterSerializer, kubeconfig_content: kubeconfig_content
  end

  def show
    respond_with resource_cluster
  end

  def destroy
    UffizziCore::ControllerService.delete_namespace(resource_cluster)
    resource_cluster.disable!

    head(:no_content)
  end

  private

  def resource_cluster
    @resource_cluster ||= resource_project.clusters.find_by!(name: params[:name])
  end

  def cluster_params
    params.require(:cluster)
  end
end
