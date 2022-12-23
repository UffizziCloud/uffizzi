# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::ComposeFile::TemplateForm
  include UffizziCore::ApplicationFormWithoutActiveRecord

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
    self.template_attributes = UffizziCore::ComposeFileService.build_template_attributes(
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
    readable_errors = [
      UffizziCore::ComposeFile::SecretsError,
      UffizziCore::ComposeFile::BuildError,
      UffizziCore::ContainerRegistryError,
    ]

    if readable_errors.include?(template_build_error.class)
      template_build_error.errors.each { |k, v| errors.add(k, v) }

      return
    end

    raise template_build_error if template_build_error.is_a?(StandardError)
  end
end
