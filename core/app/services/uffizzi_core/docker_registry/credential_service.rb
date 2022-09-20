# frozen_string_literal: true

class UffizziCore::DockerRegistry::CredentialService
  class << self
    def credential_correct?(credential)
      client(credential).authenticated?
    end

    private

    def client(credential)
      params = {
        registry_url: credential.registry_url,
        username: credential.username,
        password: credential.password,
      }

      UffizziCore::DockerRegistryClient.new(params)
    end
  end
end
