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
    cluster = UffizziCore::ClusterService.create_empty(resource_project, current_user, cluster_params[:name])

    respond_with cluster
  end

  def show
    respond_with resource_cluster
  end

  def destroy
    UffizziCore::ControllerService.delete_namespace(resource_cluster)
    resource_cluster.disable!

    head(:ok)
  end

  private

  def resource_cluster
    @resource_cluster ||= resource_project.clusters.find(params[:id])
  end

  def cluster_params
    params.require(:cluster)
  end
end
