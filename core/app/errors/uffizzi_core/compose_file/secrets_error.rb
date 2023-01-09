# frozen_string_literal: true

class UffizziCore::ComposeFile::SecretsError < UffizziCore::ComposeFileError
  def initialize(message, extra_errors = {})
    error_key = UffizziCore::ComposeFile::ErrorsService::SECRETS_ERROR_KEY

    super(message, error_key, extra_errors)
  end
end
