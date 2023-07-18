# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Deployment::CreateForm < UffizziCore::Deployment
  include UffizziCore::ApplicationForm

  permit :creation_source,
         :metadata,
         containers_attributes: [
           :image,
           :service_name,
           :tag,
           :full_image_name,
           :port,
           :public,
           :memory_limit,
           :memory_request,
           :entrypoint,
           :command,
           :receive_incoming_requests,
           :continuously_deploy,
           { variables: [:name, :value],
             additional_subdomains: [],
             secret_variables: [:name, :value],
             volumes: [:source, :target, :type, :read_only],
             healthcheck: [:test, :interval, :timeout, :retries, :start_period, :disable, { test: [] }],
             repo_attributes: [
               :namespace,
               :name,
               :slug,
               :type,
               :description,
               :is_private,
               :repository_id,
               :branch,
               :kind,
               :dockerfile_path,
               :dockerfile_context_path,
               :deploy_preview_when_image_tag_is_created,
               :delete_preview_when_image_tag_is_updated,
               :share_to_github,
               :delete_preview_after,
               { args: [:name, :value] },
             ],
             container_config_files_attributes: [
               :config_file_id,
               :mount_path,
             ],
             container_host_volume_files_attributes: [
               :host_volume_file_id,
               :source_path,
             ] },
         ]

  validate :check_all_containers_have_unique_ports
  validate :check_exists_ingress_container
  validate :check_max_memory_limit
  validate :check_max_memory_request
  validate :check_secrets_exist_in_database

  def assign_dependences!(project, user)
    self.project = project

    self.containers = containers.map do |container|
      container.repo.project = project if !container.repo.nil?

      container
    end

    self.deployed_by = user

    self
  end

  private

  def check_all_containers_have_unique_ports
    active_containers = containers.select(&:active?)

    errors.add(:containers, :duplicate_ports) unless UffizziCore::DeploymentService.all_containers_have_unique_ports?(active_containers)
  end

  def check_exists_ingress_container
    active_containers = containers.select(&:active?)

    errors.add(:containers, :incorrect_ingress_container) unless UffizziCore::DeploymentService.ingress_container?(active_containers)
  end

  def check_max_memory_limit
    return if UffizziCore::DeploymentService.valid_containers_memory_limit?(self)

    errors.add(:containers, :max_memory_limit_error, max: project.account.container_memory_limit)
  end

  def check_max_memory_request
    return if UffizziCore::DeploymentService.valid_containers_memory_request?(self)

    errors.add(:containers, :max_memory_request_error, max: project.account.container_memory_limit)
  end

  def check_secrets_exist_in_database
    return if compose_file.nil?

    existing_secrets = project.secrets.pluck('name')
    compose_file.template.payload['containers_attributes']
      .map { |container| container['secret_variables'].map { |secret| secret['name'] } }.flatten.uniq
      .select { |secret| existing_secrets.exclude?(secret) }
      .each do |secret|
      error_message = I18n.t('compose.project_secret_not_found', secret: secret)
      errors.add(:secret_variables, error_message)
    end
  end
end
