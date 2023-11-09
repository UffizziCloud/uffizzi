# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::User::Projects::ClustersController <
  UffizziCore::Api::Cli::V1::Accounts::User::Projects::ApplicationController
  def index
    clusters = resource_project.clusters.enabled.deployed_by_user(current_user).ransack(q_param)

    respond_with(clusters.result, each_serializer: UffizziCore::Api::Cli::V1::Projects::ShortClusterSerializer)
  end
end
