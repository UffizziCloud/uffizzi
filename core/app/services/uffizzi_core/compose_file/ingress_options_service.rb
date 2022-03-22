# frozen_string_literal: true

class UffizziCore::ComposeFile::IngressOptionsService
  class << self
    def parse(ingress_data, services_data)
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.no_ingress') if ingress_data.nil?

      container_name = container_name(ingress_data, services_data)
      port = port(ingress_data)

      {
        container_name: container_name,
        port: port,
      }
    end

    private

    def container_name(ingress_data, services_data)
      container_name = ingress_data['service']

      if container_name.nil?
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.ingress_service_not_found')
      end

      unless services_data.keys.include?(container_name)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_ingress_service', value: container_name)
      end

      container_name
    end

    def port(ingress_data)
      port = ingress_data['port']

      if port.nil?
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.ingress_port_not_specified')
      end

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_integer', option: :port) unless port.is_a?(Integer)

      if port < Settings.compose.port_min_value || port > Settings.compose.port_max_value
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_port')
      end

      port
    end
  end
end
