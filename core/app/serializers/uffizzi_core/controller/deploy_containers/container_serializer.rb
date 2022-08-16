# frozen_string_literal: true

class UffizziCore::Controller::DeployContainers::ContainerSerializer < UffizziCore::BaseSerializer
  attributes :id,
             :kind,
             :image,
             :tag,
             :variables,
             :secret_variables,
             :memory_limit,
             :memory_request,
             :entrypoint,
             :command,
             :port,
             :target_port,
             :public,
             :controller_name,
             :receive_incoming_requests,
             :healthcheck,
             :volumes,
             :service_name

  has_many :container_config_files

  def image
    repo = object.repo
    case repo.type
    when
      UffizziCore::Repo::Google.name,
      UffizziCore::Repo::Amazon.name,
      UffizziCore::Repo::Azure.name,
      UffizziCore::Repo::GithubContainerRegistry.name,
      UffizziCore::Repo::DockerRegistry.name

      credential = UffizziCore::RepoService.credential(repo)
      registry_host = URI.parse(credential.registry_url).host
      "#{registry_host}/#{object.image}"
    else
      object.image
    end
  end

  def tag
    object.tag
  end

  def entrypoint
    object.entrypoint.blank? ? nil : JSON.parse(object.entrypoint)
  end

  def command
    object.command.blank? ? nil : JSON.parse(object.command)
  end

  def healthcheck
    return {} if object.healthcheck.blank?

    command = object.healthcheck['test']
    new_command = if command.is_a?(Array)
      items_to_remove = ['CMD', 'CMD-SHELL']
      command.select { |item| items_to_remove.exclude?(item) }
    elsif object.healthcheck['test'].is_a?(String)
      command.split
    end

    object.healthcheck.merge('test' => new_command)
  end
end
