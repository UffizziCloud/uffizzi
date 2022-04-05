# frozen_string_literal: true

class UffizziCore::GithubContainerRegistry::CredentialService
  class << self
    def access_token(credential, image)
      client(credential, image).token
    rescue URI::InvalidURIError, Faraday::ConnectionFailed
      false
    end

    private

    def client(credential, image)
      UffizziCore::GithubContainerRegistryClient.new(registry_url: credential.registry_url, username: credential.username,
                                                     password: credential.password, image: image)
    end
  end
end
