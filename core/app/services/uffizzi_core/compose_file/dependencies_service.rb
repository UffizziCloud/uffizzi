# frozen_string_literal: true

class UffizziCore::ComposeFile::DependenciesService
  ENV_FILE_TYPE = 'env_file'
  CONFIG_TYPE = 'config'
  class << self
    def build_dependencies(compose_data, compose_path, dependencies_params)
      dependencies = compose_data[:containers].map do |container|
        env_file_dependencies = build_env_files_dependencies(container, compose_path, dependencies_params)
        configs_dependencies = build_configs_dependencies(container, compose_path, dependencies_params)

        env_file_dependencies + configs_dependencies
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
  end
end
