# frozen_string_literal: true

class UffizziCore::Controller::DeployContainers::ContainerSerializer::ContainerConfigFileSerializer < UffizziCore::BaseSerializer
  attributes :mount_path

  belongs_to :config_file
end
