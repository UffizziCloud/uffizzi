# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Account::CredentialSerializer < UffizziCore::BaseSerializer
  attributes :id, :username, :password, :type, :state

  def password
    anonymize(object.password)
  end
end
