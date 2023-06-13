# frozen_string_literal: true

class UffizziCore::ControllerService
  class << self
    include UffizziCore::DependencyInjectionConcern

    def apply_config_file(deployment, config_file)
      body = {
        config_file: UffizziCore::Controller::ApplyConfigFile::ConfigFileSerializer.new(config_file).as_json,
      }

      controller_client.apply_config_file(deployment_id: deployment.id, config_file_id: config_file.id, body: body)
    end

    def apply_credential(deployment, credential)
      image = if credential.github_container_registry?
        deployment.containers.by_repo_type(UffizziCore::Repo::GithubContainerRegistry.name).first&.image
      end

      options = { image: image }

      body = UffizziCore::Controller::CreateCredential::CredentialSerializer.new(credential, options).as_json
      controller_client.apply_credential(deployment_id: deployment.id, body: body)
    end

    def delete_credential(deployment, credential)
      controller_client.delete_credential(deployment_id: deployment.id, credential_id: credential.id)
    end

    def deploy_containers(deployment, containers)
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

      controller_client.deploy_containers(deployment_id: deployment.id, body: body)
    end

    def namespace_exists?(deployable)
      controller_client.namespace(namespace: deployable.namespace).code == 200
    end

    def fetch_deployment_events(deployment)
      request_events(deployment) || []
    end

    def fetch_pods(deployment)
      pods = controller_client.deployment_containers(deployment_id: deployment.id).result || []
      pods.filter { |pod| pod.metadata.name.start_with?(Settings.controller.namespace_prefix) }
    end

    def fetch_namespace(deployable)
      controller_client.namespace(namespace: deployable.namespace).result || nil
    end

    def create_namespace(deployable)
      # TODO: check repsonse for use present?
      body = { namespace: deployable.namespace }
      controller_client.create_namespace(body: body)
    end

    def delete_namespace(deployable)
      controller_client.delete_namespace(namespace: deployable.namespace)
    end

    def create_cluster(cluster)
      body = { cluster_name: cluster.name }
      controller_client.create_cluster(namespace: cluster.namespace, body: body)
    end

    def show_cluster(cluster)
      controller_client.show_cluster(namespace: cluster.namespace)
    end

    def delete_cluster(cluster)
      controller_client.delete_cluster(namespace: cluster.namespace)
    end

    private

    def request_events(deployment)
      controller_client.deployment_containers_events(deployment_id: deployment.id)
    end

    def controller_client
      UffizziCore::ControllerClient.new
    end
  end
end
