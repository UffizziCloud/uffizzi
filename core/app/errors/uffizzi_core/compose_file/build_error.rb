# frozen_string_literal: true

class UffizziCore::ComposeFile::BuildError < UffizziCore::ComposeFileError
  def initialize(message, extra_errors = {})
    error_key = UffizziCore::ComposeFile::ErrorsService::TEMPLATE_BUILD_ERROR_KEY

    super(message, error_key, extra_errors)
  end
end
