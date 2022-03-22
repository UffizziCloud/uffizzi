# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::DeploymentSerializer::ContainerSerializer < UffizziCore::BaseSerializer
  type :deployment

  attributes :id,
             :kind,
             :image,
             :tag,
             :variables,
             :secret_variables,
             :created_at,
             :updated_at,
             :memory_limit,
             :memory_request,
             :entrypoint,
             :command,
             :port,
             :public,
             :repo_id,
             :continuously_deploy,
             :receive_incoming_requests
end
