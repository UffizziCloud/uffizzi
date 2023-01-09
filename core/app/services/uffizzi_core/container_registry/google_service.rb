# frozen_string_literal: true

class UffizziCore::ContainerRegistry::GoogleService
  class << self
    def digest(credential, image, tag)
      response = client(credential).manifests(image: image, tag: tag)

      response.headers['docker-content-digest']
    end

    def image_available?(credential, _image_data)
      credential.present?
    end

    def credential_correct?(credential)
      client(credential).authenticated?
    end

    private

    def client(c)
      UffizziCore::GoogleRegistryClient.new(registry_url: c.registry_url, username: c.username, password: c.password)
    end
  end
end
