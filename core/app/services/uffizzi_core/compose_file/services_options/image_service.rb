# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::ImageService
  class << self
    def parse(image)
      return {} if image.blank?

      image_parts = image.downcase.split(':')
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_image_value', value: image) if image_parts.count > 2

      image_name, tag = image_parts
      tag = Settings.compose.default_tag if tag.blank?
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_image_value', value: image) if image_name.blank?

      if valid_image_url?(image_name)
        url, namespace, name = parse_image_url(image_name)
      else
        namespace, name = parse_docker_hub_image(image_name)
      end

      {
        registry_url: url,
        namespace: namespace,
        name: name,
        tag: tag,
      }
    end

    private

    def valid_image_url?(image_name)
      url = prepare_image_url(image_name)

      URI(url).host.present? && URI(url).host =~ /\w+\.\w+/ && URI(url).path.present?
    end

    def prepare_image_url(image_name)
      if image_name.start_with?('https://')
        image_name
      else
        "https://#{image_name}"
      end
    end

    def parse_image_url(image_name)
      prepared_url = prepare_image_url(image_name)

      uri = URI(prepared_url)
      url = uri.host
      path = uri.path.delete_suffix('/').delete_prefix('/')

      namespace, name = parse_image_path(path)

      [url, namespace, name]
    end

    def parse_image_path(path)
      path_parts = path.split('/', 2)

      if path_parts.count == 1
        namespace = nil
        name = path_parts.first
      else
        namespace = path_parts.first
        name = path_parts.last
      end

      [namespace, name]
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
