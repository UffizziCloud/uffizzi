# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::SecretsService
  class << self
    def parse(secrets, global_secrets_data)
      return [] if secrets.nil?

      secrets.map do |secret|
        variable_name = if secret.is_a?(String)
          process_short_syntax(secret, global_secrets_data)
        else
          raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :secrets)
        end

        variable_name
      end
    end

    private

    def process_short_syntax(secret_name, global_secrets_data)
      global_secret = find_global_secret!(secret_name, global_secrets_data)

      global_secret[:secret_variable]
    end

    def find_global_secret!(secret_name, global_secrets_data)
      detected_secret = global_secrets_data.detect { |global_secret_data| global_secret_data[:secret_name] == secret_name }
      error_message = I18n.t('compose.global_secret_not_found', secret: secret_name)
      raise UffizziCore::ComposeFile::ParseError, error_message if detected_secret.nil?

      detected_secret
    end
  end
end
