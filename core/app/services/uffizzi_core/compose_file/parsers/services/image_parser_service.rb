# frozen_string_literal: true

require 'docker_distribution'

class UffizziCore::ComposeFile::Parsers::Services::ImageParserService
  DEFAULT_TAG = Settings.compose.default_tag
  class << self
    def parse(value)
      return {} if value.blank?

      full_image_name = normalize_image_name(value)
      image_path, tag = get_image_path_and_tag(value)
      raise_parse_error(value) if image_path.blank?

      tag = DEFAULT_TAG if tag.blank?

      if url?(image_path)
        host, namespace, name = parse_image_url(image_path)
      else
        namespace, name = parse_docker_hub_image(image_path)
      end

      {
        registry_url: host,
        namespace: namespace,
        name: name,
        tag: tag,
        full_image_name: full_image_name,
      }
    end

    private

    def normalize_image_name(value)
      parse_result = DockerDistribution::Reference.parse(value)
      return value if parse_result.try(:tag).present?

      "#{value}:#{DEFAULT_TAG}"
    rescue DockerDistribution::NameContainsUppercase
      raise_parse_error(I18n.t('compose.image_name_contains_uppercase_value', value: value))
    rescue DockerDistribution::ReferenceInvalidFormat
      raise_parse_error(I18n.t('compose.invalid_image_value', value: value))
    end

    def raise_parse_error(message)
      raise UffizziCore::ComposeFile::ParseError, message
    end

    def get_image_path_and_tag(value)
      image_path_parts = value.split(':')

      case image_path_parts.size
      when 1
        image_path_parts[0]
      when 2
        uri_pattern = /\A\w[\w.-]+:\d+\//
        tag_pattern = /:\w[\w.-]*\z/
        if uri_pattern.match?(value)
          "#{image_path_parts[0]}:#{image_path_parts[1]}"
        elsif tag_pattern.match?(value)
          [image_path_parts[0], image_path_parts[1]]
        else
          raise_parse_error(value)
        end
      when 3
        ["#{image_path_parts[0]}:#{image_path_parts[1]}", image_path_parts[2]]
      else
        raise_parse_error(value)
      end
    end

    def url?(image_path)
      uri = URI(add_https_if_needed(image_path))
      uri.host.present? && uri.host =~ /(localhost(:\d+)?|\w+\.(\w+\.)*\w+)/ && uri.path.present?
    rescue URI::InvalidURIError
      false
    end

    def add_https_if_needed(image_path)
      image_path.start_with?('https://') ? image_path : "https://#{image_path}"
    end

    def parse_image_url(image_path)
      uri = URI(add_https_if_needed(image_path))
      host = "#{uri.host}:#{uri.port}"
      path = uri.path.delete_prefix('/')
      namespace, name = get_namespace_and_name(path)
      [host, namespace, name]
    end

    def get_namespace_and_name(path)
      path_parts = path.rpartition('/')

      if path_parts.first.empty?
        [nil, path_parts.last]
      else
        [path_parts.first, path_parts.last]
      end
    end

    def parse_docker_hub_image(image_name)
      if contains_account_name?(image_name)
        namespace = image_name.split('/').first
        name = image_name.split('/', 2).last.delete_suffix('/')
      else
        namespace = Settings.docker_hub.public_namespace
        name = image_name
      end

      [namespace, name]
    end

    def contains_account_name?(image_name)
      image_name_parts = image_name.split('/')

      image_name_parts.count > 1
    end
  end
end
