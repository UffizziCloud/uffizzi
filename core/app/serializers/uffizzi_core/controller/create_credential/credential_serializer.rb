# frozen_string_literal: true

class UffizziCore::Controller::CreateCredential::CredentialSerializer < UffizziCore::BaseSerializer
  attributes :id, :registry_url, :username, :password

  def username
    return 'AWS' if object.amazon?

    object.username
  end

  def password
    if object.amazon?
      UffizziCore::Amazon::CredentialService.access_token(object)
    elsif object.github_container_registry?
      UffizziCore::GithubContainerRegistry::CredentialService.access_token(object, instance_options[:image])
    else
      object.password
    end
  end
end
