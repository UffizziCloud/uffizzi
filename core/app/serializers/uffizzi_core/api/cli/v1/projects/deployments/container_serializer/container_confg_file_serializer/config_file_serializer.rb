# frozen_string_literal: true

class UffizziCore::Api::V1::Projects::Deployments::ContainerSerializer::ContainerConfigFileSerializer::ConfigFileSerializer <
  UffizziCore::BaseSerializer
  attributes :id, :filename, :kind, :payload
end
