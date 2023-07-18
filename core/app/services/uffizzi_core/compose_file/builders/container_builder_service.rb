# frozen_string_literal: true

class UffizziCore::ComposeFile::Builders::ContainerBuilderService
  attr_accessor :credentials, :project, :repositories

  def initialize(credentials, project, repositories = [])
    @credentials = credentials
    @project = project
    @repositories = repositories
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def build_attributes(container_data, ingress_data, continuous_preview_global_data, compose_dependencies)
    image_data = container_data[:image] || {}
    build_data = container_data[:build] || {}
    environment = container_data[:environment] || []
    deploy_data = container_data[:deploy] || {}
    configs_data = container_data[:configs] || []
    secrets = container_data[:secrets] || []
    container_name = container_data[:container_name]
    healthcheck_data = container_data[:healthcheck] || {}
    volumes_data = container_data[:volumes] || []

    github_deps_service = UffizziCore::ComposeFile::GithubDependenciesService

    env_file_dependencies = github_deps_service.env_file_dependencies_for_container(compose_dependencies, container_name)
    configs_dependencies = github_deps_service.configs_dependencies_for_container(compose_dependencies, container_name)
    host_volumes_dependencies = github_deps_service.host_volumes_dependencies_for_container(compose_dependencies, container_name)
    is_ingress = ingress_container?(container_name, ingress_data)
    repo_attributes = repo_attributes(container_data, continuous_preview_global_data)
    additional_subdomains = is_ingress ? ingress_data.fetch(:additional_subdomains, []) : []

    {
      tag: tag(image_data, repo_attributes),
      port: port(container_name, ingress_data),
      full_image_name: full_image_name(image_data, build_data, repo_attributes),
      image: image(container_data, image_data, build_data, credentials),
      public: is_ingress,
      entrypoint: entrypoint(container_data),
      command: command(container_data),
      variables: variables(environment, env_file_dependencies),
      secret_variables: secret_variables(secrets),
      memory_limit: memory(deploy_data),
      memory_request: memory(deploy_data),
      repo_attributes: repo_attributes,
      continuously_deploy: continuously_deploy(deploy_data),
      receive_incoming_requests: is_ingress,
      container_config_files_attributes: container_config_files_attributes(configs_data, configs_dependencies),
      service_name: container_name,
      name: container_name,
      healthcheck: healthcheck_data,
      volumes: volumes_data,
      additional_subdomains: additional_subdomains,
      container_host_volume_files_attributes: container_host_volume_files_attributes(volumes_data, host_volumes_dependencies),
    }
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def container_registry(container_data)
    @container_registry ||= UffizziCore::ContainerRegistryService.init_by_container(container_data, @credentials)
  end

  def repo_attributes(container_data, continuous_preview_global_data)
    repo_attributes = build_repo_attributes(container_data)
    continuous_preview_container_data = container_data[:'x-uffizzi-continuous-preview'] || container_data[:'x-uffizzi-continuous-previews']

    set_continuous_preview_attributes_to_repo(repo_attributes, continuous_preview_global_data.to_h, continuous_preview_container_data.to_h)
  end

  def build_repo_attributes(container_data)
    container_registry = container_registry(container_data)
    repo_type = container_registry.repo_type.name
    raise UffizziCore::ComposeFile::BuildError, I18n.t('compose.invalid_repo_type') if repo_type.blank?

    image_data = container_registry.image_data
    if container_registry.image_available?(credentials)
      docker_repo_builder = UffizziCore::ComposeFile::Builders::DockerRepoBuilderService.new(repo_type)
      return docker_repo_builder.build_attributes(image_data)
    end

    UffizziCore::ComposeFile::ErrorsService.raise_build_error!(container_registry.type)
  rescue UffizziCore::ContainerRegistryError => e
    UffizziCore::ComposeFile::ErrorsService.raise_build_error!(container_registry.type, e.errors)
  end

  def set_continuous_preview_attributes_to_repo(repo_attributes, global_data, container_data)
    condition_attributes = [
      :deploy_preview_when_image_tag_is_created,
      :delete_preview_when_image_tag_is_updated,
      :share_to_github,
    ]

    condition_attributes.each do |attribute|
      repo_attributes[attribute] = select_continuous_preview_attribute(global_data[attribute], container_data[attribute], false)
    end

    global = global_data.dig(:delete_preview_after, :value)
    local = container_data.dig(:delete_preview_after, :value)
    repo_attributes[:delete_preview_after] = select_continuous_preview_attribute(global, local, nil)

    repo_attributes
  end

  def select_continuous_preview_attribute(global_attribute, local_attribute, default_attribute)
    return local_attribute if local_attribute.present?
    return global_attribute if global_attribute.present?

    default_attribute
  end

  def tag(image_data, repo_attributes)
    image_data[:tag] || repo_attributes[:branch]
  end

  def port(container_name, ingress)
    return nil unless ingress_container?(container_name, ingress)

    ingress[:port]
  end

  def image(container_data, image_data, build_data, credentials)
    if image_data.present?
      container_registry(container_data).image_name(credentials)
    else
      "#{build_data[:account_name]}/#{build_data[:repository_name]}"
    end
  end

  def image_name(container_data)
    container_registry = container_registry(container_data)
    container_registry.image_name(credentials)
  end

  def full_image_name(image_data, build_data, repo_attributes)
    return image_data[:full_image_name] if image_data.present?

    "#{build_data[:account_name]}/#{build_data[:repository_name]}:#{repo_attributes[:branch]}"
  end

  def ingress_container?(container_name, ingress)
    ingress[:container_name] == container_name
  end

  def entrypoint(container_data)
    entrypoint = container_data[:entrypoint]
    entrypoint.present? ? entrypoint.to_s : nil
  end

  def command(container_data)
    command = container_data[:command]
    command.present? ? command.to_s : nil
  end

  def command_args(command_data)
    return nil if command_data[:command_args].blank?

    command_data[:command_args].to_s
  end

  def memory(deploy_data)
    memory = deploy_data[:memory]
    return Settings.compose.default_memory if memory.nil?

    memory_value = case memory[:postfix]
                   when 'b'
                     memory[:value] / 1_000_000
                   when 'k'
                     memory[:value] / 1000
                   when 'm'
                     memory[:value]
                   when 'g'
                     memory[:value] * 1000
    end

    unless Settings.compose.memory_values.include?(memory_value)
      raise UffizziCore::ComposeFile::BuildError,
            I18n.t('compose.invalid_memory')
    end

    memory_value
  end

  def continuously_deploy(deploy_data)
    return :disabled if deploy_data[:auto] == false

    :enabled
  end

  def variables(variables_data, dependencies)
    variables_builder.build_attributes(variables_data, dependencies)
  end

  def secret_variables(secrets)
    variables_builder.build_secret_attributes(secrets)
  end

  def container_config_files_attributes(config_files_data, dependencies)
    UffizziCore::ComposeFile::Builders::ContainerConfigFilesBuilderService.build_attributes(config_files_data, dependencies, project)
  end

  def container_host_volume_files_attributes(volumes_data, host_volumes_dependencies)
    host_volumes_data = volumes_data.select do |v|
      v[:type] == UffizziCore::ComposeFile::Parsers::Services::VolumesParserService::HOST_VOLUME_TYPE
    end

    UffizziCore::ComposeFile::Builders::ContainerHostVolumeFilesBuilderService
      .build_attributes(host_volumes_data, host_volumes_dependencies, project)
  end

  def variables_builder
    @variables_builder ||= UffizziCore::ComposeFile::Builders::VariablesBuilderService.new(project)
  end
end
