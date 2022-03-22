# frozen_string_literal: true

class UffizziCore::ComposeFile::GithubDependenciesService
  ENV_FILE_TYPE = 'env_file'
  CONFIG_TYPE = 'config'

  class << self
    def filename(dependency)
      pathname = Pathname.new(dependency[:path])

      pathname.basename.to_s
    end

    def content(dependency)
      Base64.decode64(dependency[:content])
    end

    def env_file_dependencies_for_container(dependencies, container_name)
      dependencies.select { |dependency| dependency[:type] == ENV_FILE_TYPE && dependency[:container_name] == container_name }
    end

    def configs_dependencies_for_container(dependencies, container_name)
      configs_dependencies(dependencies).select { |dependency| dependency[:container_name] == container_name }
    end

    def configs_dependencies(dependencies)
      dependencies.select { |dependency| dependency[:type] == CONFIG_TYPE }
    end

    def build_source_path(compose_path, dependency_path, repository_id, branch)
      prepared_compose_path = Pathname.new(compose_path).basename.to_s
      base_source = "#{prepared_compose_path}/#{dependency_path}"
      return base_source if repository_id.blank?

      "#{repository_id}/#{branch}/#{base_source}"
    end
  end
end
