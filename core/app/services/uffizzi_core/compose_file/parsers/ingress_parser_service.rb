# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::IngressParserService
  class << self
    def parse(ingress_data, services_data)
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.no_ingress') if ingress_data.nil?

      container_name = container_name(ingress_data, services_data)
      port = port(ingress_data)
      additional_subdomains = additional_subdomains(ingress_data)

      {
        container_name: container_name,
        port: port,
        additional_subdomains: additional_subdomains,
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

      port_min = Settings.compose.port_min_value
      port_max = Settings.compose.port_max_value
      if port < port_min || port > port_max
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.port_out_of_range', port_min: port_min, port_max: port_max)
      end

      port
    end

    def additional_subdomains(ingress_data)
      subdomains = ingress_data['additional_subdomains']

      return [] if subdomains.blank?

      subdomains.each do |subdomain|
        unless valid_subdomain?(subdomain)
          raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_additional_subdomain', subdomain: subdomain)
        end

        subdomain_max_length = Settings.deployment.subdomain.length_limit

        if subdomain.length > subdomain_max_length
          raise UffizziCore::ComposeFile::ParseError,
                I18n.t('compose.subdomain_length_limit_exceed', max_length: subdomain_max_length,
                                                                subdomain: subdomain)
        end
      end

      subdomains
    end

    def valid_subdomain?(subdomain)
      !!subdomain.match(/^[a-zA-Z0-9\-]*$/) # subdomain should contain only letters, digits, -
    end
  end
end
