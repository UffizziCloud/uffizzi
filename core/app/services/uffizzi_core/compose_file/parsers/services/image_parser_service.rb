# frozen_string_literal: true

require 'docker_distribution'

class UffizziCore::ComposeFile::Parsers::Services::ImageParserService
  DEFAULT_TAG = Settings.compose.default_tag
  class << self
    def parse(value)
      return {} if value.blank?

      parsed_image = DockerDistribution::Normalize.parse_any_reference(value)
      image_path = parsed_image.path
      namespace, name = get_namespace_and_name(image_path)
      tag = parsed_image.try(:tag) || DEFAULT_TAG
      full_image_name = "#{[parsed_image.domain, parsed_image.path].compact.join('/')}:#{tag}"

      registry_url = parsed_image.domain == 'docker.io' ? nil : parsed_image.domain

      {
        registry_url: registry_url,
        namespace: namespace,
        name: name,
        tag: tag,
        full_image_name: full_image_name,
      }
    rescue DockerDistribution::NameContainsUppercase
      raise_parse_error(I18n.t('compose.image_name_contains_uppercase_value', value: value))
    rescue DockerDistribution::ReferenceInvalidFormat, DockerDistribution::ParseNormalizedNamedError
      raise_parse_error(I18n.t('compose.invalid_image_value', value: value))
    end

    private

    def raise_parse_error(message)
      raise UffizziCore::ComposeFile::ParseError, message
    end

    def get_namespace_and_name(image_path)
      return [nil, image_path] unless image_path.index('/').present?

      image_path.split('/')
    end
  end
end
