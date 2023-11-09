# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::User::Projects::ApplicationController <
  UffizziCore::Api::Cli::V1::Accounts::User::ApplicationController
  def resource_project
    @resource_project ||= current_user.projects.find_by!(slug: params[:project_slug])
  end
end
