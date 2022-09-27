# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::VolumesParserService
  VALID_VOLUME_NAME_REGEX = /^[a-zA-Z0-9._-]+$/.freeze

  class << self
    def parse(volumes_data)
      return [] if volumes_data.nil?

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :volumes) unless volumes_data.is_a?(Hash)

      volume_names = volumes_data.keys
      volume_names.each do |volume_name|
        unless volume_name.match?(VALID_VOLUME_NAME_REGEX)
          raise UffizziCore::ComposeFile::ParseError,
                I18n.t('compose.volume_invalid_name', name: volume_name)
        end
      end

      volume_names
    end
  end
end
