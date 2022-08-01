# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::Services::ImageParserService
  class << self
    def parse(value)
      return {} if value.blank?

      parse_error = UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_image_value', value: value)
      image_path, tag = get_image_path_and_tag(value, parse_error)
      raise parse_error if image_path.blank?

      tag = Settings.compose.default_tag if tag.blank?

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
      }
    end

    private

    def get_image_path_and_tag(value, parse_error)
      image_path_parts = value.downcase.split(':')
      case image_path_parts.size
      when 1
        image_path_parts[0]
      when 2
        uri_pattern = /\A\w[\w.-]+:\d+/
        tag_pattern = /:\w[\w.-]*\z/
        if uri_pattern.match?(value)
          "#{image_path_parts[0]}:#{image_path_parts[1]}"
        elsif tag_pattern.match?(value)
          [image_path_parts[0], image_path_parts[1]]
        else
          raise parse_error
        end
      when 3
        ["#{image_path_parts[0]}:#{image_path_parts[1]}", image_path_parts[2]]
      else
        raise parse_error
      end
    end

    def url?(image_path)
      uri = URI(add_https_if_needed(image_path))
    rescue URI::InvalidURIError
      false
    else
      uri.host.present? && uri.host =~ /\w+\.(\w+\.)*\w+/ && uri.path.present?
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
