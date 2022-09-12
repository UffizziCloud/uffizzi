# frozen_string_literal: true

class UffizziCore::Controller::DeployContainers::ContainerSerializer::ContainerHostVolumeFileSerializer < UffizziCore::BaseSerializer
  attributes :host_volume_file_id, :source_path
end
