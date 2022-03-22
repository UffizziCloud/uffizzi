# frozen_string_literal: true

class UffizziCore::ComposeFile::ConfigFilesService
  def initialize(compose_file_form)
    @compose_file_form = compose_file_form
    @repository_id = compose_file_form.repository_id
    @branch = compose_file_form.branch
    @path = compose_file_form.path
    @user = compose_file_form.added_by
    @project = compose_file_form.project
  end

  def create_config_files(compose_dependencies)
    configs_dependencies = UffizziCore::ComposeFile::GithubDependenciesService.configs_dependencies(compose_dependencies)
    errors = []
    configs_dependencies.each do |config_dependency|
      errors = create_config_file(config_dependency)
      errors << errors if errors
    end

    errors
  end

  private

  def create_config_file(config_dependency)
    source = UffizziCore::ComposeFile::GithubDependenciesService.build_source_path(@path, config_dependency[:path], @repository_id, @branch)
    config_file = @project.config_files.find_or_initialize_by(source: source)
    attributes = {
      filename: UffizziCore::ComposeFile::GithubDependenciesService.filename(config_dependency),
      payload: UffizziCore::ComposeFile::GithubDependenciesService.content(config_dependency),
    }

    config_file.assign_attributes(attributes)
    config_file_form = build_config_file_form(config_file)
    return config_file_form.errors if config_file_form.invalid?

    config_file_form.save

    nil
  end

  def build_config_file_form(config_file)
    config_file_form = config_file.becomes(UffizziCore::Api::Cli::V1::ConfigFile::CreateForm)
    config_file_form.project = @project
    config_file_form.added_by = @user
    config_file_form.compose_file = @compose_file_form
    config_file_form.creation_source = UffizziCore::ConfigFile.creation_source.compose_file

    config_file_form
  end
end
