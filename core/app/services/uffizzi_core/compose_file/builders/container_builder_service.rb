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

    env_file_dependencies = UffizziCore::ComposeFile::GithubDependenciesService.env_file_dependencies_for_container(compose_dependencies,
                                                                                                                    container_name)
    configs_dependencies = UffizziCore::ComposeFile::GithubDependenciesService.configs_dependencies_for_container(compose_dependencies,
                                                                                                                  container_name)
    is_ingress = ingress_container?(container_name, ingress_data)
    repo_attributes = repo_attributes(container_data, continuous_preview_global_data)

    {
      tag: tag(image_data, repo_attributes),
      port: port(container_name, ingress_data),
      image: image(container_data, image_data, build_data),
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
      container_config_files_attributes: config_files(configs_data, configs_dependencies),
      service_name: container_name,
      name: container_name,
      healthcheck: healthcheck_data,
      volumes: volumes_data,
    }
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def repo_attributes(container_data, continuous_preview_global_data)
    repo_attributes = build_repo_attributes(container_data)
    continuous_preview_container_data = container_data[:'x-uffizzi-continuous-preview'] || container_data[:'x-uffizzi-continuous-previews']

    set_continuous_preview_attributes_to_repo(repo_attributes, continuous_preview_global_data.to_h, continuous_preview_container_data.to_h)
  end

  def set_continuous_preview_attributes_to_repo(repo_attributes, global_data, container_data)
    condition_attributes = [
      :deploy_preview_when_pull_request_is_opened,
      :delete_preview_when_pull_request_is_closed,
      :deploy_preview_when_image_tag_is_created,
      :delete_preview_when_image_tag_is_updated,
      :share_to_github,
    ]

    condition_attributes.each do |attribute|
      repo_attributes[attribute] = select_continuous_preview_attribute(global_data[attribute], container_data[attribute], false)
    end
    repo_attributes[:delete_preview_after] =
      select_continuous_preview_attribute(global_data.dig(:delete_preview_after, :value),
                                          container_data.dig(:delete_preview_after, :value), nil)

    repo_attributes
  end

  def select_continuous_preview_attribute(global_attribute, local_attribute, default_attribute)
    return local_attribute if !local_attribute.nil?
    return global_attribute if !global_attribute.nil?

    default_attribute
  end

  def tag(image_data, repo_attributes)
    image_data[:tag] || repo_attributes[:branch]
  end

  def port(container_name, ingress)
    return nil unless ingress_container?(container_name, ingress)

    ingress[:port]
  end

  def image(container_data, image_data, build_data)
    if image_data.present?
      image_name(container_data, image_data)
    else
      "#{build_data[:account_name]}/#{build_data[:repository_name]}"
    end
  end

  def image_name(container_data, image_data)
    if image_data[:registry_url].present? &&
        !UffizziCore::ComposeFile::ContainerService.google?(container_data) &&
        !UffizziCore::ComposeFile::ContainerService.github_container_registry?(container_data)
      image_data[:name]
    else
      "#{image_data[:namespace]}/#{image_data[:name]}"
    end
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

  def build_repo_attributes(container_data)
    repo_type = repo_type(container_data)
    image_data = container_data[:image]

    case repo_type
    when UffizziCore::Repo::DockerHub.name
      build_docker_repo_attributes(image_data, credentials, :docker_hub, UffizziCore::Repo::DockerHub.name)
    when UffizziCore::Repo::Azure.name
      build_docker_repo_attributes(image_data, credentials, :azure, UffizziCore::Repo::Azure.name)
    when UffizziCore::Repo::Google.name
      build_docker_repo_attributes(image_data, credentials, :google, UffizziCore::Repo::Google.name)
    when UffizziCore::Repo::GithubContainerRegistry.name
      build_docker_repo_attributes(image_data, credentials, :github_container_registry, UffizziCore::Repo::GithubContainerRegistry.name)
    when UffizziCore::Repo::Amazon.name
      build_docker_repo_attributes(image_data, credentials, :amazon, UffizziCore::Repo::Amazon.name)
    else
      raise UffizziCore::ComposeFile::BuildError, I18n.t('compose.invalid_repo_type')
    end
  end

  def repo_type(container_data)
    if UffizziCore::ComposeFile::ContainerService.azure?(container_data)
      UffizziCore::Repo::Azure.name
    elsif UffizziCore::ComposeFile::ContainerService.docker_hub?(container_data)
      UffizziCore::Repo::DockerHub.name
    elsif UffizziCore::ComposeFile::ContainerService.google?(container_data)
      UffizziCore::Repo::Google.name
    elsif UffizziCore::ComposeFile::ContainerService.github_container_registry?(container_data)
      UffizziCore::Repo::GithubContainerRegistry.name
    elsif UffizziCore::ComposeFile::ContainerService.amazon?(container_data)
      UffizziCore::Repo::Amazon.name
    end
  end

  def continuously_deploy(deploy_data)
    return :disabled if deploy_data[:auto] == false

    :enabled
  end

  def build_docker_repo_attributes(image_data, credentials, scope, repo_type)
    credential = credentials.send(scope).first
    raise UffizziCore::ComposeFile::BuildError, I18n.t('compose.invalid_credential', value: scope) if credential.nil?

    docker_builder(repo_type).build_attributes(image_data)
  end

  def variables(variables_data, dependencies)
    variables_builder.build_attributes(variables_data, dependencies)
  end

  def secret_variables(secrets)
    variables_builder.build_secret_attributes(secrets)
  end

  def config_files(config_files_data, dependencies)
    builder = UffizziCore::ComposeFile::Builders::ConfigFilesBuilderService.new(project)

    builder.build_attributes(config_files_data, dependencies)
  end

  def docker_builder(type)
    @docker_builder ||= UffizziCore::ComposeFile::Builders::DockerRepoBuilderService.new(type)
  end

  def variables_builder
    @variables_builder ||= UffizziCore::ComposeFile::Builders::VariablesBuilderService.new(project)
  end
end
