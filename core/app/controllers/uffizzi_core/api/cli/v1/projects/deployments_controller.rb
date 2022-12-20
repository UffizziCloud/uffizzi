# frozen_string_literal: true

# @resource Deployment

class UffizziCore::Api::Cli::V1::Projects::DeploymentsController < UffizziCore::Api::Cli::V1::Projects::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_projects_deployments

  include UffizziCore::Concerns::Controllers::Api::Cli::V1::Projects::DeploymentsController
end
