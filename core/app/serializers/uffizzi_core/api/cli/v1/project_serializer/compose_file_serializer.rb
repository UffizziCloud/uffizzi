# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer::ComposeFileSerializer < UffizziCore::BaseSerializer
  type :compose_file

  attributes :source
end
