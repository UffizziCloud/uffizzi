# frozen_string_literal: true

class UffizziCore::DockerRegistryService
  class << self
    def image_available?(credential, image_data)
      client_params = build_client_params(credential, image_data)
      client = UffizziCore::DockerRegistryClient.new(**client_params)
      response = client.manifests(namespace: image_data[:namespace], image: image_data[:name], tag: image_data[:tag])

      response.status < 400
    end

    private

    def build_client_params(credential, image_data)
      registry_url = credential&.registry_url || image_data[:registry_url]
      new_registry_url = registry_url.start_with?('https://', 'http://') ? registry_url : "https://#{registry_url}"

      {
        registry_url: new_registry_url,
        username: credential&.username,
        password: credential&.password,
      }
    end
  end
end
