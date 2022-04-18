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

  def secret_variables
    return unless object.secret_variables.present?

    object.secret_variables.map do |var|
      { name: var['name'], value: anonymize(var['value']) }
    end
  end
end
