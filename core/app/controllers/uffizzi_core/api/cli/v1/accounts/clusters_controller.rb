# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::ClustersController < UffizziCore::Api::Cli::V1::Accounts::ApplicationController
  include UffizziCore::DependencyInjectionConcern
  before_action :authorize_uffizzi_core_api_cli_v1_accounts_clusters

  def index
    return respond_with(clusters_by_account.includes(:project)) if valid_request_from_ci_workflow?

    clusters = clusters_by_user.or(clusters_by_admin_projects)
    respond_with(clusters.includes(:project))
  end

  private

  def valid_request_from_ci_workflow?
    ci_module.valid_request_from_ci_workflow?(params)
  end

  def clusters_by_admin_projects
    projects = UffizziCore::Project
      .active
      .joins(:user_projects)
      .where(account: resource_account)
      .where(user_projects: { role: UffizziCore::UserProject.role.admin, user: current_user })

    UffizziCore::Cluster.enabled.where(project_id: projects.select(:id))
  end

  def clusters_by_user
    UffizziCore::Cluster.enabled.by_projects(account_projects).deployed_by_user(current_user)
  end

  def clusters_by_account
    UffizziCore::Cluster.enabled.by_projects(account_projects)
  end

  def account_projects
    UffizziCore::Project.active.where(account: resource_account)
  end
end
