# frozen_string_literal: true

# @resource Project

class UffizziCore::Api::Cli::V1::ProjectsController < UffizziCore::Api::Cli::V1::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_projects

  # Get projects of current user
  #
  # @path [GET] /api/cli/v1/projects
  #
  # @response [object<projects: Array<object<slug: string, name: string>> >] 200 OK
  # @response 401 Not authorized
  def index
    projects = current_user.projects.active.order(updated_at: :desc)

    respond_with projects, each_serializer: UffizziCore::Api::Cli::V1::ShortProjectSerializer
  end

  # Get a project by slug
  #
  # @path [GET] /api/cli/v1/projects/{slug}
  #
  # @response <object< project: Project>> 200 OK
  # @response 404 Not Found
  # @response 401 Not authorized
  def show
    project = current_user.projects.find_by!(slug: params[:slug])

    respond_with project
  end

  # Create a project
  #
  # @path [POST] /api/cli/v1/projects
  # @parameter params(required,body) [object<name: string, slug: string, description: string>]
  #
  # @response <object< project: Project>> 200 OK
  # @response 404 Not Found
  # @response 401 Not authorized
  # @response [object<errors: object<password: string >>] 422 Unprocessable entity

  def create
    project_form = UffizziCore::Api::Cli::V1::Project::CreateForm.new(project_params)
    project_form.account = current_user.organizational_account

    if project_form.save
      current_membership = current_user.memberships.find_by(account: current_user.organizational_account)
      user_projects = []

      if current_membership.developer?
        user_projects << { project: project_form, user: current_user, role: UffizziCore::UserProject.role.developer }
      end

      current_user.organizational_account.memberships.where(role: UffizziCore::Membership.role.admin).map do |membership|
        user_projects << { project: project_form, user: membership.user, role: UffizziCore::UserProject.role.admin }
      end

      UffizziCore::UserProject.create!(user_projects)
    end

    respond_with project_form
  end

  # Delete a project
  #
  # @path [DELETE] /api/cli/v1/projects/{slug}
  #
  # @response 204 No content
  # @response 404 Not Found
  # @response 401 Not authorized

  def destroy
    project = current_user.organizational_account.active_projects.find_by!(slug: params[:slug])
    project.disable!

    head :no_content
  end

  private

  def project_params
    params.require(:project)
  end
end
