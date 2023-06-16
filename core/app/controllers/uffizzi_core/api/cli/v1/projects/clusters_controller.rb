# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClustersController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  include UffizziCore::Api::Cli::V1::Projects::ClustersControllerModule

  before_action :authorize_uffizzi_core_api_cli_v1_projects_clusters
  after_action :update_show_trial_quota_exceeded_warning, only: [:create, :destroy]

  def index
    clusters = resource_project.clusters.enabled

    respond_with clusters
  end

  def create
    cluster_form = UffizziCore::Api::Cli::V1::Cluster::CreateForm.new(cluster_params)
    cluster_form.project = resource_project
    cluster_form.deployed_by = current_user
    return respond_with cluster_form unless cluster_form.save

    cluster_data = UffizziCore::ClusterService.create_empty(cluster_form)

    render json: { cluster: cluster_data }, status: :created
  end

  def show
    cluster_data = UffizziCore::ControllerService.show_cluster(resource_cluster)

    render json: { cluster: cluster_data }, status: :ok
  end

  def destroy
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
