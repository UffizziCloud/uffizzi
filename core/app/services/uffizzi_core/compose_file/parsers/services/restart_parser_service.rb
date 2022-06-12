# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::Services::RestartParserService
  class << self
    def parse(restart_data)
      return nil if restart_data.nil?

      parse_restart(restart_data)
    end

    private

    def parse_restart(restart_data)
      case restart_data
      when 'always'
        'Always'
      when 'on-failure'
        'OnFailure'
      when 'no'
        'Never'
      else
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_restart_option', option: :restart)
      end
    end
  end
end
