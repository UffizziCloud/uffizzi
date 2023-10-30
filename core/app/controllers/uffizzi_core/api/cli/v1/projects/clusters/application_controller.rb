# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Clusters::ApplicationController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  def resource_cluster
    @resource_cluster ||= if request_by_admin? || valid_request_from_ci_workflow?
      active_project_clusters.find_by!(name: params[:cluster_name])
    else
      active_project_clusters.deployed_by_user(current_user).find_by!(name: params[:cluster_name])
    end
  end

  private

  def active_project_clusters
    @active_project_clusters ||= resource_project.clusters.enabled
  end

  def request_by_admin?
    current_user.admin_access_to_project?(resource_project)
  end

  def valid_request_from_ci_workflow?
    ci_module.valid_request_from_ci_workflow?(params)
  end

  def policy_context
    UffizziCore::Project::ClusterContext.new(current_user, resource_project, user_access_module, resource_cluster, params)
  end
end
