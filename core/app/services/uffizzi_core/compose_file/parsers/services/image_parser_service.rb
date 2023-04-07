# frozen_string_literal: true

require 'docker_distribution'

class UffizziCore::ComposeFile::Parsers::Services::ImageParserService
  DEFAULT_TAG = Settings.compose.default_tag
  class << self
    def parse(value)
      return {} if value.blank?

      parsed_image = DockerDistribution::Normalize.parse_docker_ref(value)
      image_path = parsed_image.path
      namespace, name = get_namespace_and_name(image_path)

      full_image_name = "#{[parsed_image.domain, parsed_image.path].compact.join('/')}:#{parsed_image.tag}"

      {
        registry_url: parsed_image.domain,
        namespace: namespace,
        name: name,
        tag: parsed_image.tag,
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
