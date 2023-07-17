# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ShortClusterSerializer < UffizziCore::BaseSerializer
  type :cluster

  attributes :name, :state
end
