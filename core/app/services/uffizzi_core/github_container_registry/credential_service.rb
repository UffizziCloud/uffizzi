# frozen_string_literal: true

class UffizziCore::GithubContainerRegistry::CredentialService
  class << self
    def credential_correct?(credential)
      client(credential).authentificated?
    rescue URI::InvalidURIError, Faraday::ConnectionFailed
      false
    end

    def access_token(credential)
      client(credential).token
    rescue URI::InvalidURIError, Faraday::ConnectionFailed
      false
    end

    private

    def client(credential)
      UffizziCore::GithubContainerRegistryClient.new(registry_url: credential.registry_url, username: credential.username,
                                                     password: credential.password)
    end
  end
end
