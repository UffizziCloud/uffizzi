# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Accounts::ClusterSerializer < UffizziCore::BaseSerializer
  type :cluster

  belongs_to :project

  attributes :name
end
