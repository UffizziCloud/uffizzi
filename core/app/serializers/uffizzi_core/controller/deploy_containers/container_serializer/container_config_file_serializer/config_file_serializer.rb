# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
class UffizziCore::Controller::DeployContainers::ContainerSerializer::ContainerConfigFileSerializer::ConfigFileSerializer < UffizziCore::BaseSerializer
  # rubocop:enable Metrics/LineLength

  attributes :id, :filename, :kind, :payload
end
