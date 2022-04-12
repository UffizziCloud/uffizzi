# frozen_string_literal: true

class UffizziCore::Controller::DeployContainers::ContainerSerializer::ContainerConfigFileSerializer::ConfigFileSerializer < UffizziCore::BaseSerializer
  attributes :id, :filename, :kind, :payload
end
