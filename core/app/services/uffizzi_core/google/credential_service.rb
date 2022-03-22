# frozen_string_literal: true

class UffizziCore::Google::CredentialService
  class << self
    def credential_correct?(credential)
      client(credential).authentificated?
    rescue URI::InvalidURIError, Faraday::ConnectionFailed
      false
    end

    private

    def client(credential)
      UffizziCore::GoogleRegistryClient.new(registry_url: credential.registry_url, username: credential.username,
                                            password: credential.password)
    end
  end
end
