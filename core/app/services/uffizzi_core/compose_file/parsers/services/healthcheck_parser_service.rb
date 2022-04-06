# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::Services::HealthcheckParserService
  REQUIRED_START_COMMANDS = ['NONE', 'CMD', 'CMD-SHELL'].freeze

  class << self
    def parse(healthcheck_data)
      return {} if deploy_data.blank?

      command = parse_command(healthcheck_data)
      # test: ["CMD", "curl", "-f", "http://localhost"]
      # interval: 1m30s
      # timeout: 10s
      # retries: 3
      # start_period: 40s
      # disable: true

      {
        test: command,
      }
    end

    private

    def parse_command(healthcheck_data)
      command = healthcheck_data['test']
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.string_or_array_error', option: :test) if command.nil?

      case command
      when Array
        start_command = command.first
        raise UffizziCore::ComposeFile::ParseError unless REQUIRED_START_COMMANDS.include?(start_command)

        command
      when String
        command
      else
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :test)
      end
    end
  end
end
