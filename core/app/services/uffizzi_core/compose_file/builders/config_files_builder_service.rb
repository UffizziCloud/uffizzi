# frozen_string_literal: true

class UffizziCore::ComposeFile::Builders::ConfigFilesBuilderService
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def build_attributes(config_files_data, dependencies)
    return [] if config_files_data.empty?

    config_file_sources = dependencies.pluck(:source)
    config_files = project.config_files.with_creation_source(UffizziCore::ConfigFile.creation_source.compose_file)
      .by_source(config_file_sources)

    config_files_data.map do |config_file_data|
      detected_dependency = dependencies.detect { |dependency| dependency[:path] == config_file_data[:source] }
      detected_config_file = config_files.detect { |config_file| config_file.source == detected_dependency[:source] }

      if detected_config_file.nil?
        raise UffizziCore::ComposeFile::BuildError, I18n.t('compose.config_file_not_found', name: config_file_data[:source])
      end

      {
        mount_path: config_file_data[:target],
        config_file_id: detected_config_file.id,
      }
    end
  end
end
