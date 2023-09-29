# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClustersController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  include UffizziCore::Api::Cli::V1::Projects::ClustersControllerModule

  before_action :authorize_uffizzi_core_api_cli_v1_projects_clusters
  before_action :check_account_quota, only: [:create]
  after_action :update_show_trial_quota_exceeded_warning, only: [:create, :destroy]

  def index
    clusters = resource_project.clusters.enabled
    return respond_with clusters if request_by_admin? || valid_request_from_ci_workflow?

    respond_with clusters.deployed_by_user(current_user)
  end

  def create
    cluster_form = UffizziCore::Api::Cli::V1::Cluster::CreateForm.new(cluster_params)
    cluster_form.project = resource_project
    cluster_form.deployed_by = current_user
    return respond_with cluster_form unless cluster_form.save

    UffizziCore::ClusterService.start_deploy(cluster_form)

    respond_with cluster_form
  end

  def scale_down
    if resource_cluster.deployed?
      UffizziCore::ClusterService.scale_down!(resource_cluster)
      return respond_with resource_cluster
    end

    return render_invalid_transition(I18n.t('cluster.already_asleep', name: resource_cluster.name)) if resource_cluster.scaled_down?

    if resource_cluster.deploying_namespace? || resource_cluster.deploying?
      render_invalid_transition(I18n.t('cluster.deploy_in_process', name: resource_cluster.name))
    end
  rescue AASM::InvalidTransition => e
    render_invalid_transition(e.message)
  end

  def scale_up
    if resource_cluster.scaled_down?
      UffizziCore::ClusterService.scale_up!(resource_cluster)
      return respond_with resource_cluster
    end

    return render_invalid_transition(I18n.t('cluster.already_awake', name: resource_cluster.name)) if resource_cluster.deployed?
  rescue AASM::InvalidTransition => e
    render_invalid_transition(e)
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
    active_project_clusters = resource_project.clusters.enabled
    @resource_cluster ||= if request_by_admin? || valid_request_from_ci_workflow?
      active_project_clusters.find_by!(name: params[:name])
    else
      active_project_clusters.deployed_by_user(current_user).find_by!(name: params[:name])
    end
  end

  def request_by_admin?
    current_user.admin_access_to_project?(resource_project)
  end

  def valid_request_from_ci_workflow?
    ci_module.valid_request_from_ci_workflow?(params)
  end

  def cluster_params
    params.require(:cluster)
  end

  def render_invalid_transition(message)
    render json: { errors: { state: [message] } }, status: :unprocessable_entity
  end
end
