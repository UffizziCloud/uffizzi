# frozen_string_literal: true

# @resource Project

class UffizziCore::Api::Cli::V1::Accounts::ProjectsController < UffizziCore::Api::Cli::V1::Accounts::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_accounts_projects

  # Create a project
  #
  # @path [POST] /api/cli/v1/accounts/{account_id}/projects
  # @parameter params(required,body) [object<name: string, slug: string, description: string>]
  #
  # @response <object< project: Project>> 200 OK
  # @response 404 Not Found
  # @response 401 Not authorized
  # @response [object<errors: object<password: string >>] 422 Unprocessable entity

  def create
    project_form = UffizziCore::Api::Cli::V1::Project::CreateForm.new(project_params)
    project_form.account = current_user.default_account

    if project_form.save
      UffizziCore::ProjectService.add_users_to_project!(project_form, current_user)
    end

    respond_with project_form
  end

  private

  def project_params
    params.require(:project)
  end
end
