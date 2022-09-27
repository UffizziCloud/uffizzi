# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::DeploymentsSerializer::UserSerializer < UffizziCore::BaseSerializer
  type :user

  attributes :email
end
