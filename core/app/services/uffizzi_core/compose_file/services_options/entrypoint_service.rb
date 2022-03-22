# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::EntrypointService
  class << self
    def parse(entrypoint_data)
      return nil if entrypoint_data.blank?

      case entrypoint_data
      when String
        [entrypoint_data]
      when Array
        entrypoint_data
      else
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :entrypoint)
      end
    end
  end
end
