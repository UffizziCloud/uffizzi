# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::UserSerializer < UffizziCore::BaseSerializer
  type :user

  attributes :default_account

  def default_account
    UffizziCore::Api::Cli::V1::UserSerializer::AccountSerializer.new(object.default_account)
  end
end
