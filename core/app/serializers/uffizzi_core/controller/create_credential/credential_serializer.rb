# frozen_string_literal: true

class UffizziCore::Controller::CreateCredential::CredentialSerializer < UffizziCore::BaseSerializer
  attributes :id, :registry_url, :username, :password

  def username
    return 'AWS' if object.amazon?

    object.username
  end

  def password
    return UffizziCore::Amazon::CredentialService.access_token(object) if object.amazon?

    object.password
  end
end
