# frozen_string_literal: true

class UffizziCore::ComposeFile::SecretsOptionsService
  class << self
    def parse(secrets_data)
      return [] if secrets_data.nil?

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :secrets) unless secrets_data.is_a?(Hash)

      secrets = []
      secrets_data.each_pair do |secret_name, secret_data|
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.secret_name_blank', option: secret_name) if secret_data['name'].blank?

        if secret_data['external'] != true
          raise UffizziCore::ComposeFile::ParseError,
                I18n.t('compose.secret_external', secret: secret_name)
        end

        secrets << {
          secret_name: secret_name,
          secret_variable: secret_data['name'],
        }
      end

      secrets
    end
  end
end
