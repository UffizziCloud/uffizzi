# frozen_string_literal: true

# rubocop:disable Layout/LineLength
class UffizziCore::Controller::DeployContainers::ContainerSerializer::ContainerConfigFileSerializer::ConfigFileSerializer < UffizziCore::BaseSerializer
  # rubocop:enable Layout/LineLength

  attributes :id, :filename, :kind, :payload
end
