# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer::DeploymentSerializer < UffizziCore::BaseSerializer
  type :deployment

  attributes :id,
             :preview_url,
             :state

  def preview_url
    UffizziCore::DeploymentService.build_preview_url(object)
  end
end
