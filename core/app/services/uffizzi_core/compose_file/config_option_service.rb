# frozen_string_literal: true

class UffizziCore::ComposeFile::ConfigOptionService
  class << self
    def valid_option_format?(option)
      if option.is_a?(TrueClass) || option.is_a?(FalseClass)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.boolean_option', value: option)
      end

      option.match(/^[a-zA-Z_][a-zA-Z0-9._\-]+$/).present?
    end

    def config_options(compose_data)
      compose_data.each_with_object([]) do |(key, value), keys|
        keys << key
        keys.concat(config_options(value)) if value.is_a?(Hash)
      end
    end

    def prepare_file_path_value(file_path)
      pathname = Pathname.new(file_path)

      pathname.cleanpath.to_s.strip.delete_prefix('/')
    end

    def ingress_option(compose_data)
      compose_data.dig('x-uffizzi', 'ingress').presence || compose_data['x-uffizzi-ingress'].presence
    end

    def continuous_preview_option(compose_data)
      compose_data.dig('x-uffizzi', 'continuous_preview').presence ||
        compose_data.dig('x-uffizzi', 'continuous_previews').presence ||
        compose_data['x-uffizzi-continuous-preview'].presence ||
        compose_data['x-uffizzi-continuous-previews'].presence
    end
  end
end
