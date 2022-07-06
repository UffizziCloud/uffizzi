# frozen_string_literal: true

class UffizziCore::GoogleService
  class << self
    def digest(credential, image, tag)
      response = registry_client(credential).manifests(image: image, tag: tag)

      response.headers['docker-content-digest']
    end

    private

    def registry_client(credential)
      UffizziCore::GoogleRegistryClient.new(
        registry_url: credential.registry_url,
        username: credential.username,
        password: credential.password,
      )
    end
  end
end
