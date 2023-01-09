# frozen_string_literal: true

class UffizziCore::ContainerRegistry::AzureService
  class << self
    def image_available?(credential, _image_data)
      credential.present?
    end

    def credential_correct?(credential)
      client(credential).authenticated?
    end

    private

    def client(c)
      UffizziCore::AzureRegistryClient.new(registry_url: c.registry_url, username: c.username, password: c.password)
    end
  end
end
