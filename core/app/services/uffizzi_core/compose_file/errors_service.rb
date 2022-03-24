# frozen_string_literal: true

class UffizziCore::ComposeFile::ErrorsService
  SECRETS_ERROR_KEY = 'secret_variables'
  class << self
    def has_error?(compose_file, error_code)
      error = compose_file.payload.dig('errors', error_code)

      error.present?
    end

    def has_errors?(compose_file)
      compose_file.payload['errors'].present?
    end

    def update_compose_errors!(compose_file, errors, invalid_content)
      compose_file.payload['errors'] = errors
      compose_file.set_invalid if compose_file.valid_file?
      compose_file.content = invalid_content

      compose_file.save!

      compose_file
    end

    def reset_compose_errors!(compose_file)
      compose_file.payload['errors'] = nil
      compose_file.set_valid

      compose_file.save!

      compose_file
    end

    def reset_error!(compose_file, error_code)
      errors = compose_file.payload['errors']
      return if errors.nil?

      new_errors = errors.except(error_code)
      compose_file.payload['errors'] = new_errors
      compose_file.save!

      compose_file
    end
  end
end
