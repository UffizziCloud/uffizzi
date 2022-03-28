# frozen_string_literal: true

class UffizziCore::Api::V1::Projects::Deployments::ContainerSerializer::ContainerConfigFileSerializer < UffizziCore::BaseSerializer
  attributes :id, :mount_path

  belongs_to :config_file
end
