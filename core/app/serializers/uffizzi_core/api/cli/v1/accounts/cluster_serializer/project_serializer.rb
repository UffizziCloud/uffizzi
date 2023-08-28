# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::ClusterSerializer::ProjectSerializer < UffizziCore::BaseSerializer
  type :project

  attributes :name
end
