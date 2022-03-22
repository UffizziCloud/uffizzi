# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ComposeFileSerializer < UffizziCore::BaseSerializer
  type :compose_file

  attributes :id, :source, :path, :auto_deploy, :state, :payload, :content
end
