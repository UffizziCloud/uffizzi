# frozen_string_literal: true

class UffizziCore::Controller::CreateCredential::CredentialSerializer < UffizziCore::BaseSerializer
  attributes :id, :registry_url, :username, :password

  def username
    return 'AWS' if object.amazon?

    object.username
  end

  def password
    if object.amazon?
      UffizziCore::ContainerRegistry::AmazonService.access_token(object)
    else
      object.password
    end
  end
end
