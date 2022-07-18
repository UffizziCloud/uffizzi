# frozen_string_literal: true

class UffizziCore::DockerRegistry::CredentialService
  class << self
    def credentials_correct?(credentials)
      client(credentials).authenticated?
    end

    private

    def client(credentials)
      UffizziCore::DockerRegistryClient.new(credentials)
    end
  end
end
