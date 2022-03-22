# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ApplicationController < UffizziCore::Api::Cli::V1::ApplicationController
  def resource_project
    @resource_project ||= current_user.projects.find_by!(slug: params[:project_slug])
  end
end
