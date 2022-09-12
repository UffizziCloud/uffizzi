# frozen_string_literal: true

class UffizziCore::Controller::DeployContainers::HostVolumeFileSerializer < UffizziCore::BaseSerializer

  attributes :id, :source, :path, :payload, :is_file

  def payload
    Base64.encode64(object.payload)
  end
end
