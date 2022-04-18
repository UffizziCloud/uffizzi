# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::Services::HealthcheckParserService
  REQUIRED_START_COMMANDS = ['NONE', 'CMD', 'CMD-SHELL'].freeze

  class << self
    def parse(healthcheck_data)
      return {} if healthcheck_data.blank?

      command = parse_command(healthcheck_data)

      {
        test: command,
        interval: parse_time(healthcheck_data['interval']),
        timeout: parse_time(healthcheck_data['timeout']),
        retries: healthcheck_data['retries'],
        start_period: parse_time(healthcheck_data['start_period']),
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

    def parse_retries(value)
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_integer', option: :retries) unless value.is_a?(Integer)
    end

    def parse_time(value)
      tokens = {
        "s" => (1),
        "m" => (60),
        "h" => (60 * 60),
        "d" => (60 * 60 * 24)
      }

      interval_in_seconds = 0

      time_parts = value.scan(/(\d+)(\w)/).compact

      time_parts.reduce(0) do |acc, part|
        amount, measure = part
        acc += amount.to_i * tokens[measure]

        acc
      rescue Exception
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_time_interval', option: :test) if command.nil?
      end
    end
  end
end
