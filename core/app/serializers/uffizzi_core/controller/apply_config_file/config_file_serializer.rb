# frozen_string_literal: true

class UffizziCore::Controller::ApplyConfigFile::ConfigFileSerializer < UffizziCore::BaseSerializer
  attributes :id, :filename, :kind, :payload
end
