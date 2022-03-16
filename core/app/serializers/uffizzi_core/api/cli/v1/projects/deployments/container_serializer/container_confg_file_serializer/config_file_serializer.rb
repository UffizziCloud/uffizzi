# frozen_string_literal: true

class UffizzCore::Api::V1::Projects::Deployments::ContainerSerializer::ContainerConfigFileSerializer::ConfigFileSerializer <
  UffizzCore::BaseSerializer
  attributes :id, :filename, :kind, :payload
end
