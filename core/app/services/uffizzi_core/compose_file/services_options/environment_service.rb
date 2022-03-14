# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::EnvironmentService
  extend UffizziCore::ComposeFile::VariablesService

  class << self
    def parse(environment)
      return [] if environment.blank?

      case environment
      when Array
        environment.map { |variable| parse_variable_from_string(variable) }
      when Hash
        environment.to_a.map { |variable| parse_variable_from_array(variable) }
      else
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :environment)
      end
    end
  end
end
