# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ApplicationController < UffizziCore::ApplicationController
  before_action :authenticate_request!

  def resource_project
    @resource_project ||= current_user.projects.find_by!(slug: params[:slug])
  end

  def resource_account
    @resource_account ||= resource_project.account
  end
end
