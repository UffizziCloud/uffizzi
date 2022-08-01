# frozen_string_literal: true

class UffizziCore::DockerRegistry::CredentialService
  class << self
    def credential_correct?(credential)
      client(credential).authenticated?
    end

    private

    def client(credential)
      UffizziCore::DockerRegistryClient.new(credential)
    end
  end
end
