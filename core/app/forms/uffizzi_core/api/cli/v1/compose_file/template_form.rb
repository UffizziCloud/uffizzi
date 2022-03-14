# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::TemplateForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

  SECRETS_ERROR_KEY = 'secret_variables'
  TEMPLATE_BUILD_ERROR_KEY = 'template_build_error'

  attribute :credentials
  attribute :project, UffizziCore::Project
  attribute :user, UffizziCore::User
  attribute :compose_data, Hash
  attribute :source, String
  attribute :template_attributes, Hash
  attribute :template_build_error, String
  attribute :compose_dependencies, Array
  attribute :compose_repositories, Array

  validate :check_template_attributes

  def assign_template_attributes!
    self.template_attributes = UffizziCore::Cli::ComposeFileService.build_template_attributes(
      compose_data,
      source,
      credentials,
      project,
      compose_dependencies,
      compose_repositories,
    )
  rescue StandardError => e
    self.template_build_error = e
  end

  private

  def check_template_attributes
    case template_build_error
    when UffizziCore::ComposeFile::SecretsError
      errors.add(SECRETS_ERROR_KEY, template_build_error.message)
    when UffizziCore::ComposeFile::BuildError
      errors.add(TEMPLATE_BUILD_ERROR_KEY, template_build_error.message)
    end
  end
end
