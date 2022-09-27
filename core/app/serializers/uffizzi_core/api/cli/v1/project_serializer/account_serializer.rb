# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ProjectSerializer::AccountSerializer < UffizziCore::BaseSerializer
  attributes :id, :kind, :state, :name
end
