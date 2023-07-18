# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClustersController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  include UffizziCore::Api::Cli::V1::Projects::ClustersControllerModule

  before_action :authorize_uffizzi_core_api_cli_v1_projects_clusters
  before_action :check_account_quota, only: [:create]
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

    UffizziCore::ClusterService.start_deploy(cluster_form)

    respond_with cluster_form
  end

  def show
    respond_with resource_cluster
  end

  def destroy
    resource_cluster.disable!

    head(:no_content)
  end

  private

  def resource_cluster
    @resource_cluster ||= resource_project.clusters.enabled.find_by!(name: params[:name])
  end

  def cluster_params
    params.require(:cluster)
  end
end
