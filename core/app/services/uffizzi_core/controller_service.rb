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

    def create_deployment(deployment)
      body = UffizziCore::Controller::CreateDeployment::DeploymentSerializer.new(deployment).as_json
      controller_client.create_deployment(deployment_id: deployment.id, body: body)
    end

    def update_deployment(deployment)
      body = UffizziCore::Controller::UpdateDeployment::DeploymentSerializer.new(deployment).as_json
      controller_client.update_deployment(deployment_id: deployment.id, body: body)
    end

    def delete_deployment(deployment_id)
      controller_client.delete_deployment(deployment_id: deployment_id)
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

      body = {
        containers: containers,
        credentials: credentials,
        deployment_url: deployment.preview_url,
      }

      if password_protection_module.present?
        body = password_protection_module.add_password_configuration(body, deployment.project_id)
      end

      controller_client.deploy_containers(deployment_id: deployment.id, body: body)
    end

    def deployment_exists?(deployment)
      controller_client.deployment(deployment_id: deployment.id).code == 200
    end

    def fetch_deployment_events(deployment)
      request_events(deployment) || []
    end

    def fetch_pods(deployment)
      pods = controller_client.deployment_containers(deployment_id: deployment.id).result || []
      pods.filter { |pod| pod.metadata.name.start_with?(Settings.controller.namespace_prefix) }
    end

    def fetch_namespace(deployment)
      controller_client.deployment(deployment_id: deployment.id).result || nil
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
