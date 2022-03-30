# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ApplicationController < UffizziCore::Api::Cli::V1::ApplicationController
  def resource_project
    @resource_project ||= current_user.projects.find_by!(slug: params[:project_slug])
  end

  def policy_context
    UffizziCore::ProjectContext.new(current_user, user_access_module, resource_project, params)
  end
end
