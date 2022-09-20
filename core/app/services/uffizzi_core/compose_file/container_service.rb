# frozen_string_literal: true

class UffizziCore::ComposeFile::ContainerService
  class << self
    def azure?(container)
      registry_url = container.dig(:image, :registry_url)

      registry_url.present? && registry_url.include?('azurecr.io')
    end

    def google?(container)
      registry_url = container.dig(:image, :registry_url)

      registry_url.present? && registry_url.include?('gcr.io')
    end

    def amazon?(container)
      registry_url = container.dig(:image, :registry_url)

      registry_url.present? && registry_url.include?('amazonaws.com')
    end

    def docker_hub?(container)
      registry_url = container.dig(:image, :registry_url)
      repository_url = container.dig(:build, :repository_url)

      registry_url.nil? && repository_url.nil?
    end

    def docker_registry?(container)
      registry_url = container.dig(:image, :registry_url)
      return false if registry_url.nil?

      registry_domain_regexp = /(\w+\.\w{2,})(?::\d+)?\z/
      registry_domain = registry_url.match(registry_domain_regexp)&.to_a&.last
      return false if registry_domain.nil?

      ['amazonaws.com', 'azurecr.io', 'gcr.io', 'ghcr.io'].exclude?(registry_domain)
    end

    def github_container_registry?(container)
      registry_url = container.dig(:image, :registry_url)

      registry_url.present? && registry_url.include?('ghcr.io')
    end

    def has_secret?(container, secret)
      container['secret_variables'].any? { |container_secret| container_secret['name'] == secret['name'] }
    end

    def update_secret(container, secret)
      secret_index = container['secret_variables'].find_index { |container_secret| container_secret['name'] == secret['name'] }
      container['secret_variables'][secret_index] = secret

      container
    end

    def credential_for_container(container, credentials)
      if UffizziCore::ComposeFile::ContainerService.azure?(container)
        detect_credential(container, credentials, :azure)
      elsif UffizziCore::ComposeFile::ContainerService.docker_hub?(container)
        detect_credential(container, credentials, :docker_hub)
      elsif UffizziCore::ComposeFile::ContainerService.google?(container)
        detect_credential(container, credentials, :google)
      else
        detect_credential(container, credentials, :docker_registry)
      end
    end

    def detect_credential(container, credentials, type)
      credential = credentials.detect { |item| item.send("#{type}?") }

      return credential if image_available?(credential, container[:image], type)

      raise UffizziCore::ComposeFile::CredentialError.new(I18n.t('compose.unprocessable_image', value: type))
    end

    def image_available?(credential, image_data, type)
      case type
      when :docker_hub
        UffizziCore::DockerHubService.image_available?(credential, image_data)
      when :docker_registry
        UffizziCore::DockerRegistryService.image_available?(credential, image_data)
      else
        # TODO check image availability in other registry types
        credential.present?
      end
    end
  end
end
