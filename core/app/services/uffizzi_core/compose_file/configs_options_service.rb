# frozen_string_literal: true

class UffizziCore::ComposeFile::ConfigsOptionsService
  class << self
    def parse(configs_data)
      return [] if configs_data.nil?

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :configs) unless configs_data.is_a?(Hash)

      configs = []
      configs_data.each_pair do |config_name, config_data|
        if config_data['file'].blank?
          raise UffizziCore::ComposeFile::ParseError,
                I18n.t('compose.config_file_option_empty', config_name: config_name)
        end

        configs << {
          config_name: config_name,
          config_file: config_data['file'],
        }
      end

      configs
    end
  end
end
