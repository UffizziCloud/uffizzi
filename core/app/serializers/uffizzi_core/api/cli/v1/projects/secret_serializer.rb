# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::SecretSerializer < UffizziCore::BaseSerializer
  attributes :name, :created_at, :updated_at
end
