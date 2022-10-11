# frozen_string_literal: true

class UffizziCore::ComposeFile::DependenciesService
  ENV_FILE_TYPE = 'env_file'
  CONFIG_TYPE = 'config'
  VOLUME_TYPE = 'volume'
  DEPENDENCY_CONFIG_USE_KIND = 'config_map'
  DEPENDENCY_VOLUME_USE_KIND = 'volume'

  class << self
    def build_dependencies(compose_data, compose_path, dependencies_params)
      config_dependencies_params = dependencies_params.select { |d| d[:use_kind] == DEPENDENCY_CONFIG_USE_KIND }
      volume_dependencies_params = dependencies_params.select { |d| d[:use_kind] == DEPENDENCY_VOLUME_USE_KIND }

      dependencies = compose_data[:containers].map do |container|
        env_file_dependencies = build_env_files_dependencies(container, compose_path, config_dependencies_params)
        configs_dependencies = build_configs_dependencies(container, compose_path, config_dependencies_params)
        volumes_dependencies = build_volumes_dependencies(container, compose_path, volume_dependencies_params)

        env_file_dependencies + configs_dependencies + volumes_dependencies
      end

      dependencies.compact.flatten
    end

    def build_env_files_dependencies(container, compose_path, dependencies_params)
      env_files = container[:env_file]
      return [] unless env_files.present?

      env_files.map do |path|
        dependency = dependencies_params.detect { |item| item[:path] == path }
        source = build_source_path(compose_path, path)

        base_file_params(dependency, container).merge(source: source, type: ENV_FILE_TYPE)
      end
    end

    def build_configs_dependencies(container, compose_path, dependencies_params)
      configs = container[:configs]
      return [] unless configs.present?

      configs.map do |config|
        dependency = dependencies_params.detect { |item| item[:path] == config[:source] }
        source = build_source_path(compose_path, dependency[:path])

        base_file_params(dependency, container).merge(source: source, type: CONFIG_TYPE)
      end
    end

    def build_volumes_dependencies(container, compose_path, raw_dependencies)
      container_volumes = container[:volumes]
      return [] unless container_volumes.present?

      container_volumes
        .select { |c| c[:type] == UffizziCore::ComposeFile::Parsers::Services::VolumesParserService::HOST_VOLUME_TYPE }
        .map do |container_volume|
          detected_raw_dependency = raw_dependencies.detect { |raw_dependency| raw_dependency[:source] == container_volume[:source] }
          builded_source = build_source_path(compose_path, detected_raw_dependency[:source])

          {
            content: detected_raw_dependency[:content],
            path: detected_raw_dependency[:path],
            container_name: container[:container_name],
            source: builded_source,
            raw_source: detected_raw_dependency[:source],
            type: VOLUME_TYPE,
            is_file: detected_raw_dependency[:is_file],
          }
        end
    end

    def base_file_params(dependency, container)
      {
        content: dependency[:content],
        path: dependency[:path],
        container_name: container[:container_name],
      }
    end

    def build_source_path(compose_path, dependency_path)
      prepared_compose_path = Pathname.new(compose_path).basename.to_s
      "#{prepared_compose_path}/#{dependency_path}"
    end

    def host_volume_binary_content(dependency)
      Base64.decode64(dependency[:content])
    end
  end
end
