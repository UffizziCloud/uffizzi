# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::ConfigsService
  class << self
    def parse(configs, global_configs_data)
      return [] if configs.nil?

      configs.map do |config|
        config_data = case config
                      when String
                        process_short_syntax(config, global_configs_data)
                      when Hash
                        process_long_syntax(config, global_configs_data)
                      else
                        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :configs)
        end

        config_data
      end
    end

    private

    def process_short_syntax(config_name, global_configs_data)
      global_config = find_global_config!(config_name, global_configs_data)

      {
        source: UffizziCore::ComposeFile::ConfigOptionService.prepare_file_path_value(global_config[:config_file]),
        target: global_config[:config_file],
      }
    end

    def process_long_syntax(config_data, global_configs_data)
      global_config = find_global_config!(config_data['source'], global_configs_data)
      target = config_data['target'].blank? ? global_config[:config_file] : config_data['target']

      {
        source: UffizziCore::ComposeFile::ConfigOptionService.prepare_file_path_value(global_config[:config_file]),
        target: target,
      }
    end

    def find_global_config!(config_name, global_configs_data)
      detected_config = global_configs_data.detect { |global_config_data| global_config_data[:config_name] == config_name }

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.global_config_not_found', config: config_name) if detected_config.nil?

      detected_config
    end
  end
end
