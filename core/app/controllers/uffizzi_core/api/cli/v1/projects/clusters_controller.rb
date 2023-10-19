# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClustersController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  include UffizziCore::Api::Cli::V1::Projects::ClustersControllerModule

  before_action :authorize_uffizzi_core_api_cli_v1_projects_clusters
  before_action :check_account_quota, only: [:create]
  after_action :update_show_trial_quota_exceeded_warning, only: [:create, :destroy]

  def index
    clusters = resource_project.clusters.enabled
    return respond_with clusters if request_by_admin? || valid_request_from_ci_workflow?

    respond_with clusters.deployed_by_user(current_user), each_serializer: UffizziCore::Api::Cli::V1::Projects::ShortClusterSerializer
  end

  def create
    version = cluster_params[:k8s_version]
    kubernetes_distribution = find_kubernetes_distribution(version)
    return render_distribution_version_error(version) if kubernetes_distribution.blank?

    cluster_form = UffizziCore::Api::Cli::V1::Cluster::CreateForm.new(cluster_params)
    cluster_form.project = resource_project
    cluster_form.deployed_by = current_user
    cluster_form.kubernetes_distribution = kubernetes_distribution
    return respond_with cluster_form unless cluster_form.save

    UffizziCore::ClusterService.start_deploy(cluster_form)

    respond_with cluster_form
  end

  def scale_down
    if resource_cluster.deployed?
      UffizziCore::ClusterService.scale_down!(resource_cluster)
      return respond_with resource_cluster
    end

    return render_scale_error(I18n.t('cluster.already_asleep', name: resource_cluster.name)) if resource_cluster.scaled_down?

    if resource_cluster.deploying_namespace? || resource_cluster.deploying?
      render_scale_error(I18n.t('cluster.deploy_in_process', name: resource_cluster.name))
    end
  rescue AASM::InvalidTransition, UffizziCore::ClusterScaleError => e
    render_scale_error(e.message)
  end

  def scale_up
    if resource_cluster.scaled_down?
      UffizziCore::ClusterService.scale_up!(resource_cluster)
      return respond_with resource_cluster
    end

    return render_scale_error(I18n.t('cluster.already_awake', name: resource_cluster.name)) if resource_cluster.deployed?
  rescue AASM::InvalidTransition, UffizziCore::ClusterScaleError => e
    render_scale_error(e.message)
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

  def render_scale_error(message)
    render json: { errors: { state: [message] } }, status: :unprocessable_entity
  end

  def find_kubernetes_distribution(version)
    return UffizziCore::KubernetesDistribution.default if version.blank?

    UffizziCore::KubernetesDistribution.find_by(version: version)
  end

  def render_distribution_version_error(version)
    available_versions = UffizziCore::KubernetesDistribution.pluck(:version).join(', ')
    message = I18n.t('kubernetes_distribution.not_available', version: version, available_versions: available_versions)
    render json: { errors: { kubernetes_distribution: [message] } }, status: :unprocessable_entity
  end
end
