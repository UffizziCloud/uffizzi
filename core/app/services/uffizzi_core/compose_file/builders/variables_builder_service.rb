# frozen_string_literal: true

class UffizziCore::ComposeFile::Builders::VariablesBuilderService
  attr_accessor :project

  require 'dotenv'

  def initialize(project)
    @project = project
  end

  def build_attributes(variables_data, dependencies)
    variables = variables_data
    variables_from_dependencies = variables_from_dependencies(dependencies)

    variables + variables_from_dependencies
  end

  def build_secret_attributes(secrets)
    project_secrets = project.secrets || []

    secrets.uniq.map do |secret|
      detected_secret = project_secrets.detect { |project_secret| project_secret['name'] == secret }
      error_message = I18n.t('compose.project_secret_not_found', secret: secret)
      raise UffizziCore::ComposeFile::SecretsError, error_message if detected_secret.nil?

      build_variable(detected_secret['name'], detected_secret['value'])
    end
  end

  private

  def variables_from_dependencies(dependencies)
    variables = dependencies.map do |dependency|
      variables_data = parse_variables_from_dependency(dependency)

      variables_data.map { |variable_data| build_variable(variable_data.first, variable_data.last) }
    end

    variables.flatten
  end

  def parse_variables_from_dependency(dependency)
    content = dependency[:content]
    return [] if content.blank?

    variables_content = UffizziCore::ComposeFile::GithubDependenciesService.content(dependency)
    parser = Dotenv::Parser.new(variables_content)
    parser.call.to_a
  end

  def build_variable(name, value)
    {
      name: name,
      value: value,
    }
  end
end
