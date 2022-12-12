# frozen_string_literal: true

class UffizziCore::ContainerRegistry::GithubContainerRegistryService
  class << self
    def image_available?(credential, _image_data)
      credential.present?
    end

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

    def client(c)
      UffizziCore::GithubContainerRegistryClient.new(registry_url: c.registry_url, username: c.username, password: c.password)
    end
  end
end
