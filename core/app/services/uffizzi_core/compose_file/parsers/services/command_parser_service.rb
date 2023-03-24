# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::Services::CommandParserService
  class << self
    def parse(command_data)
      return nil if command_data.blank?

      case command_data
      when String
        Shellwords.split(command_data)
      when Array
        command_data
      else
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :command)
      end
    end
  end
end
