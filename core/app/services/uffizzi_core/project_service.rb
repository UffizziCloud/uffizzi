# frozen_string_literal: true

module UffizziCore::ProjectService
  class << self
    def update_compose_secrets(project)
      compose_file = project.compose_file
      return if compose_file&.template.nil?

      project.secrets.each do |secret|
        if UffizziCore::ComposeFileService.has_secret?(compose_file, secret)
          UffizziCore::ComposeFileService.update_secret!(compose_file, secret)
        end
      end

      return unless UffizziCore::ComposeFileService.secrets_valid?(compose_file, project.secrets)

      secrets_error_key = UffizziCore::ComposeFile::ErrorsService::SECRETS_ERROR_KEY
      return unless UffizziCore::ComposeFile::ErrorsService.has_error?(compose_file, secrets_error_key)

      UffizziCore::ComposeFile::ErrorsService.reset_error!(compose_file, secrets_error_key)
      compose_file.set_valid! unless UffizziCore::ComposeFile::ErrorsService.has_errors?(compose_file)
    end

    def update_compose_secret_errors(project, secret)
      compose_file = project.compose_file
      return if compose_file.nil?
      return unless UffizziCore::ComposeFileService.has_secret?(compose_file, secret)

      error_message = I18n.t('compose.project_secret_not_found', secret: secret['name'])
      error = { UffizziCore::ComposeFile::ErrorsService::SECRETS_ERROR_KEY => [error_message] }

      existing_errors = compose_file.payload['errors'].presence || {}
      new_errors = existing_errors.merge(error)

      UffizziCore::ComposeFile::ErrorsService.update_compose_errors!(compose_file, new_errors, compose_file.content)
    end
  end
end
