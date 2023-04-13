# frozen_string_literal: true

class UffizziCore::ContainerRegistryService
  attr_accessor :type, :container_data

  class << self
    def init_by_subclass(credential_type)
      type = credential_type.demodulize.underscore
      new(type.to_sym)
    end

    def init_by_container(container)
      registry_url = container.dig(:image, :registry_url)

      return new(:docker_hub, container) if registry_url.include?('docker.io')
      return new(:azure, container) if registry_url.include?('azurecr.io')
      return new(:google, container) if registry_url.include?('gcr.io')
      return new(:amazon, container) if registry_url.include?('amazonaws.com')
      return new(:github_container_registry, container) if registry_url.include?('ghcr.io')
      return new(:docker_registry, container) if docker_registry?(container)
    end

    def docker_registry?(container)
      registry_url = container.dig(:image, :registry_url)
      return false if registry_url.nil?

      registry_domain_regexp = /(\w+\.\w{2,})(?::\d+)?\z/
      registry_domain = registry_url.match(registry_domain_regexp)&.to_a&.last
      return false if registry_domain.nil?

      ['amazonaws.com', 'azurecr.io', 'gcr.io', 'ghcr.io'].exclude?(registry_domain)
    end

    def sources
      [:azure, :google, :amazon, :github_container_registry, :docker_registry, :docker_hub, *additional_sources]
    end

    def additional_sources
      []
    end
  end

  def initialize(type, container_data = {})
    @type = type
    @container_data = container_data

    raise ::UffizziCore::RegistryNotSupportedError unless self.class.sources.include?(type)
  end

  def digest(credential, image, tag)
    service.digest(credential, image, tag)
  end

  def service
    @service ||= "UffizziCore::ContainerRegistry::#{type.to_s.camelize}Service".safe_constantize
  end

  def repo_type
    @repo_type ||= "UffizziCore::Repo::#{type.to_s.camelize}".safe_constantize
  end

  def credential_correct?(credential)
    service.credential_correct?(credential)
  rescue URI::InvalidURIError, Faraday::ConnectionFailed, UffizziCore::ContainerRegistryError
    false
  end

  def image_data
    @image_data ||= container_data[:image]
  end

  def image_name(credentials)
    if image_data[:registry_url].present? && [:google, :github_container_registry, :docker_registry, :docker_hub].exclude?(type)
      return image_data[:name]
    end

    if type == :docker_registry && credential(credentials).nil?
      return [image_data[:registry_url], image_data[:namespace], image_data[:name]].compact.join('/')
    end

    "#{image_data[:namespace]}/#{image_data[:name]}"
  end

  def credential(credentials_scope)
    credentials_scope.send(type).first
  end

  def image_available?(credentials_scope)
    credential = credential(credentials_scope)
    service.image_available?(credential, image_data)
  end
end
