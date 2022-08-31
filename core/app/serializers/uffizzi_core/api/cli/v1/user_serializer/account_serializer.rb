# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::UserSerializer::AccountSerializer < UffizziCore::BaseSerializer
  attributes :id, :kind, :state, :name
end
