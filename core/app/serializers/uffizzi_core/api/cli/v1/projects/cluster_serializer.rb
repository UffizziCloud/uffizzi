# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::ClusterSerializer < UffizziCore::BaseSerializer
  type :cluster

  attributes :name, :state, :kube_config
end
