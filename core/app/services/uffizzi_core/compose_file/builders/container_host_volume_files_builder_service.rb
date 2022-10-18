# frozen_string_literal: true

class UffizziCore::ComposeFile::Builders::ContainerHostVolumeFilesBuilderService
  class << self
    def build_attributes(container_host_volumes_data, host_volumes_dependencies, project)
      return [] if container_host_volumes_data.empty?

      host_volume_files = project
        .host_volume_files
        .by_source(host_volumes_dependencies.pluck(:source))

      container_host_volumes_data.map do |container_host_volume_data|
        detected_dependency = host_volumes_dependencies.detect do |dependency|
          dependency[:raw_source] == container_host_volume_data[:source]
        end
        detected_host_volume_file = host_volume_files.detect { |host_volume_file| host_volume_file.source == detected_dependency[:source] }

        if detected_host_volume_file.nil?
          raise UffizziCore::ComposeFile::BuildError,
                I18n.t('compose.host_volume_file_not_found', name: container_host_volume_data[:source])
        end

        {
          source_path: container_host_volume_data[:source],
          host_volume_file_id: detected_host_volume_file.id,
        }
      end
    end
  end
end
