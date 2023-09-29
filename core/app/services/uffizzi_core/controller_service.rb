# frozen_string_literal: true

class UffizziCore::ControllerService
  class InvalidPublicPort < StandardError
    def initialize(containers)
      msg = "Deployment with ID #{containers.first.deployment.id} does not have any public port"

      super(msg)
    end
  end

  class << self
    include UffizziCore::DependencyInjectionConcern

    def apply_config_file(deployment, config_file)
      body = {
        config_file: UffizziCore::Controller::ApplyConfigFile::ConfigFileSerializer.new(config_file).as_json,
      }

      controller_client(deployment).apply_config_file(deployment_id: deployment.id, config_file_id: config_file.id, body: body)
    end

    def apply_credential(deployment, credential)
      image = if credential.github_container_registry?
        deployment.containers.by_repo_type(UffizziCore::Repo::GithubContainerRegistry.name).first&.image
      end

      options = { image: image }

      body = UffizziCore::Controller::CreateCredential::CredentialSerializer.new(credential, options).as_json
      controller_client(deployment).apply_credential(deployment_id: deployment.id, body: body)
    end

    def delete_credential(deployment, credential)
      controller_client(deployment).delete_credential(deployment_id: deployment.id, credential_id: credential.id)
    end

    def deploy_containers(deployment, containers)
      check_any_container_has_public_port(containers) do |exists|
        UffizziCore::DeploymentService.disable!(deployment) unless exists
      end

      containers = containers.map do |container|
        UffizziCore::Controller::DeployContainers::ContainerSerializer.new(container).as_json(include: '**')
      end

      credentials = deployment.credentials.deployable.map do |credential|
        UffizziCore::Controller::DeployContainers::CredentialSerializer.new(credential).as_json
      end

      host_volume_files = UffizziCore::HostVolumeFile.by_deployment(deployment).map do |host_volume_file|
        UffizziCore::Controller::DeployContainers::HostVolumeFileSerializer.new(host_volume_file).as_json
      end

      compose_file = if deployment.compose_file.present?
        UffizziCore::Controller::DeployContainers::ComposeFileSerializer.new(deployment.compose_file).as_json
      end

      body = {
        containers: containers,
        credentials: credentials,
        deployment_url: deployment.preview_url,
        compose_file: compose_file,
        host_volume_files: host_volume_files,
      }

      if password_protection_module.present?
        body = password_protection_module.add_password_configuration(body, deployment.project_id)
      end

      controller_client(deployment).deploy_containers(deployment_id: deployment.id, body: body)
    end

    def namespace_exists?(deployable)
      controller_client(deployable).namespace(namespace: deployable.namespace).code == 200
    end

    def fetch_deployment_events(deployment)
      request_events(deployment) || []
    end

    def fetch_pods(deployment)
      pods = controller_client(deployment).deployment_containers(deployment_id: deployment.id).result || []
      pods.filter { |pod| pod.metadata.name.start_with?(Settings.controller.namespace_prefix) }
    end

    def fetch_namespace(deployable)
      controller_client(deployable).namespace(namespace: deployable.namespace).result || nil
    end

    def create_namespace(deployable)
      body = { namespace: deployable.namespace }
      controller_client(deployable).create_namespace(body: body).result || nil
    end

    def delete_namespace(deployable)
      controller_client(deployable).delete_namespace(namespace: deployable.namespace)
    end

    def create_cluster(cluster)
      body = UffizziCore::Controller::CreateCluster::ClusterSerializer.new(cluster).as_json
      controller_client(cluster).create_cluster(namespace: cluster.namespace, body: body).result
    end

    def show_cluster(cluster)
      controller_client(cluster).show_cluster(namespace: cluster.namespace, name: cluster.name).result
    end

    def delete_cluster(cluster)
      controller_client(cluster).delete_cluster(namespace: cluster.namespace)
    end

    def update_cluster(cluster, sleep:)
      body = UffizziCore::Controller::UpdateCluster::ClusterSerializer.new(cluster).as_json
      body[:sleep_after] = '3600'
      body[:sleep] = sleep

      controller_client(cluster).update_cluster(name: cluster.name, namespace: cluster.namespace, body: body)
    end

    private

    def check_any_container_has_public_port(containers)
      exists = containers.any? { |c| c.port.present? && c.public }
      yield(exists) if block_given?

      return if exists

      raise InvalidPublicPort.new(containers)
    end

    def request_events(deployment)
      controller_client(deployment).deployment_containers_events(deployment_id: deployment.id)
    end

    def controller_client(deployable)
      settings = case deployable
                 when UffizziCore::Deployment
                   Settings.controller
                 when UffizziCore::Cluster
                   controller_settings_service.vcluster(deployable)
                 else
                   raise StandardError, "Deployable #{deployable.class.name} undefined"
      end

      UffizziCore::ControllerClient.new(settings)
    end
  end
end
