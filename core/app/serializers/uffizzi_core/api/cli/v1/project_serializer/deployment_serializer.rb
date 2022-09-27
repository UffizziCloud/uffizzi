# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer::DeploymentSerializer < UffizziCore::BaseSerializer
  type :deployment

  attributes :id,
             :preview_url,
             :state
end
