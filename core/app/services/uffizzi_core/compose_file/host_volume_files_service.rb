# frozen_string_literal: true

class UffizziCore::ComposeFile::HostVolumeFilesService
  class << self
    def bulk_create(compose_file_form, compose_dependencies)
      volumes_dependencies = UffizziCore::ComposeFile::GithubDependenciesService.
        select_dependencies_by_type(compose_dependencies, UffizziCore::ComposeFile::DependenciesService::VOLUME_TYPE)

      errors = []
      volumes_dependencies.each do |volume_dependency|
        new_errors = create(compose_file_form, volume_dependency)
        errors << new_errors if new_errors
      end

      errors
    end

    def create(compose_file_form, volume_dependency)
      source = volume_dependency[:source]
      host_volume_file = compose_file_form.project.host_volume_files.find_or_initialize_by(source: source)
      attributes = {
        payload: UffizziCore::ComposeFile::DependenciesService.host_volume_binary_content(volume_dependency),
        source: source,
        path: volume_dependency[:path],
        is_file: volume_dependency[:is_file],
      }

      host_volume_file.assign_attributes(attributes)
      host_volume_file.project = compose_file_form.project
      host_volume_file.added_by = compose_file_form.added_by
      host_volume_file.compose_file = compose_file_form

      return host_volume_file.errors if host_volume_file.invalid?

      host_volume_file.save

      nil
    end
  end
end
