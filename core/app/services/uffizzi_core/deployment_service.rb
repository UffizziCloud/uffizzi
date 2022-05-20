# frozen_string_literal: true

class UffizziCore::DeploymentService
  MIN_TARGET_PORT_RANGE = 37_000
  MAX_TARGET_PORT_RANGE = 39_999

  DEPLOYMENT_PROCESS_STATUSES = {
    building: :building,
    deploying: :deploying,
    failed: :failed,
    queued: :queued,
  }.freeze

  class << self
    def create_from_compose(compose_file, project, user)
      deployment_attributes = ActionController::Parameters.new(compose_file.template.payload)
      deployment_form = UffizziCore::Api::Cli::V1::Deployment::CreateForm.new(deployment_attributes)
      deployment_form.assign_dependences!(project, user)
      deployment_form.compose_file = compose_file
      deployment_form.creation_source = UffizziCore::Deployment.creation_source.compose_file_manual

      if deployment_form.save
        update_subdomain!(deployment_form)

        UffizziCore::Deployment::CreateJob.perform_async(deployment_form.id)
        UffizziCore::Deployment::CreateWebhooksJob.perform_async(deployment_form.id)
      end

      deployment_form
    end

    def update_from_compose(compose_file, project, user, deployment)
      deployment_attributes = ActionController::Parameters.new(compose_file.template.payload)

      deployment_form = UffizziCore::Api::Cli::V1::Deployment::UpdateForm.new(deployment_attributes)
      deployment_form.assign_dependences!(project, user)
      deployment_form.compose_file = compose_file

      ActiveRecord::Base.transaction do
        deployment.containers.destroy_all
        deployment.compose_file.destroy! if deployment.compose_file.kind.temporary?

        deployment.update!(containers: deployment_form.containers, compose_file_id: compose_file.id)
      end

      deployment_form
    end

    def deploy_containers(deployment, repeated = false)
      if !repeated
        create_activity_items(deployment)
        update_controller_container_names(deployment)
      end

      case deployment_process_status(deployment)
      when DEPLOYMENT_PROCESS_STATUSES[:building]
        Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment.id} repeat deploy_containers")
        UffizziCore::Deployment::DeployContainersJob.perform_in(1.minute, deployment.id, true)
      when DEPLOYMENT_PROCESS_STATUSES[:deploying]
        Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment.id} start deploying into controller")

        containers = deployment.active_containers
        containers = add_default_deployment_variables!(containers)

        UffizziCore::ControllerService.deploy_containers(deployment, containers)
      else
        Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment.id} deployment has builds errors, stopping")
      end
    end

    def disable!(deployment)
      deployment.disable!
      compose_file = deployment.compose_file || deployment.template&.compose_file
      return unless compose_file&.kind&.temporary?

      compose_file.destroy!
    end

    def fail!(deployment)
      deployment.fail!
      compose_file = deployment.compose_file || deployment.template&.compose_file
      return unless compose_file&.kind&.temporary?

      compose_file.destroy!
    end

    def build_subdomain(deployment)
      if deployment.continuous_preview_payload.present?
        continuous_preview_payload = deployment.continuous_preview_payload

        return build_pull_request_subdomain(deployment) if continuous_preview_payload['pull_request'].present?
        return build_docker_continuous_preview_subdomain(deployment) if continuous_preview_payload['docker'].present?
      end

      build_default_subdomain(deployment)
    end

    def build_pull_request_subdomain(deployment)
      project = deployment.project
      continuous_preview_payload = deployment.continuous_preview_payload
      pull_request_payload = continuous_preview_payload['pull_request']
      repo_name = pull_request_payload['repository_full_name'].split('/').last
      deployment_name = name(deployment)
      subdomain = "pr#{pull_request_payload['id']}-#{deployment_name}-#{repo_name}-#{project.slug}"

      format_subdomain(subdomain)
    end

    def build_docker_continuous_preview_subdomain(deployment)
      project = deployment.project
      continuous_preview_payload = deployment.continuous_preview_payload
      docker_payload = continuous_preview_payload['docker']
      repo_name = docker_payload['image'].split('/').last
      image_tag = docker_payload['tag']
      deployment_name = name(deployment)
      subdomain = "#{image_tag}-#{deployment_name}-#{repo_name}-#{project.slug}"

      format_subdomain(subdomain)
    end

    def build_default_subdomain(deployment)
      deployment_name = name(deployment)
      slug = deployment.project.slug.to_s
      subdomain = "#{deployment_name}-#{slug}"

      format_subdomain(subdomain)
    end

    def build_preview_url(deployment)
      "#{deployment.subdomain}.#{Settings.app.managed_dns_zone}"
    end

    def build_deployment_url(deployment)
      "#{Settings.app.managed_dns_zone}/projects/#{deployment.project_id}/deployments"
    end

    def all_containers_have_unique_ports?(containers)
      ports = containers.map(&:port).compact
      containers.empty? || ports.size == ports.uniq.size
    end

    def valid_containers_memory_limit?(deployment)
      containers = deployment.containers
      container_memory_limit = deployment.project.account.container_memory_limit
      return true if container_memory_limit.nil?

      containers.all? { |container| container.memory_limit <= container_memory_limit }
    end

    def valid_containers_memory_request?(deployment)
      containers = deployment.containers
      container_memory_limit = deployment.project.account.container_memory_limit
      return true if container_memory_limit.nil?

      containers.all? { |container| container.memory_request <= container_memory_limit }
    end

    def ingress_container?(containers)
      containers.empty? || containers.map(&:receive_incoming_requests).count(true) == 1
    end

    def find_unused_port(deployment)
      selected_port = nil

      Timeout.timeout(20) do
        loop do
          selected_port = rand(MIN_TARGET_PORT_RANGE..MAX_TARGET_PORT_RANGE)

          break if !deployment.containers.exists?(target_port: selected_port)
        end
      end

      selected_port
    end

    def setup_ingress_container(deployment, ingress_container, port)
      old_deployment_subdomain = deployment.subdomain

      containers = deployment.containers.active

      UffizziCore::Container.transaction do
        containers.update_all(receive_incoming_requests: false, port: nil, public: false)
        containers.find(ingress_container.id).update!(port: port, public: true, receive_incoming_requests: true)
      end

      deployment.reload

      new_deployment_subdomain = build_subdomain(deployment)

      if new_deployment_subdomain != old_deployment_subdomain
        deployment.update(subdomain: new_deployment_subdomain)
      end

      UffizziCore::Deployment::DeployContainersJob.perform_async(deployment.id)
    end

    def name(deployment)
      "deployment-#{deployment.id}"
    end

    def update_subdomain!(deployment)
      deployment.subdomain = build_subdomain(deployment)

      deployment.save!
    end

    def create_webhooks(deployment)
      credential = deployment.project.account.credentials.docker_hub.active.first

      if !deployment.containers.with_docker_hub_repo.exists? || !credential.present?
        Rails.logger.info("DEPLOYMENT_PROCESS deployment_id=#{deployment.id} create_webhooks no dockerhub containers or credential")
        return
      end

      accounts = UffizziCore::DockerHubService.accounts(credential)

      deployment.containers.with_docker_hub_repo.find_each do |container|
        if !accounts.include?(container.repo.namespace)
          logger_message = "DEPLOYMENT_PROCESS deployment_id=#{deployment.id} no namespace(#{container.repo.namespace})
          in accounts(#{accounts.inspect})"
          Rails.logger.info(logger_message)
          next
        end

        UffizziCore::Credential::DockerHub::CreateWebhookJob.perform_async(credential.id, container.image, deployment.id)
      end
    end

    def pull_request_payload_present?(deployment)
      deployment.continuous_preview_payload.present? && deployment.continuous_preview_payload['pull_request'].present?
    end

    def failed?(deployment)
      deployment_status = deployment_process_status(deployment)

      deployment_status == DEPLOYMENT_PROCESS_STATUSES[:failed]
    end

    private

    def deployment_process_status(deployment)
      containers = deployment.active_containers
      activity_items = containers.map { |container| container.activity_items.order_by_id.last }.compact
      events = activity_items.map { |activity_item| activity_item.events.order_by_id.last&.state }
      events = events.flatten.uniq

      return DEPLOYMENT_PROCESS_STATUSES[:queued] if events.empty?
      return DEPLOYMENT_PROCESS_STATUSES[:failed] if events.include?(UffizziCore::Event.state.failed)
      return DEPLOYMENT_PROCESS_STATUSES[:building] if events.include?(UffizziCore::Event.state.building)

      DEPLOYMENT_PROCESS_STATUSES[:deploying]
    end

    def create_activity_items(deployment)
      deployment.active_containers.each do |container|
        repo = container.repo
        activity_item = UffizziCore::ActivityItemService.create_docker_item!(repo, container)

        create_default_activity_item_event(activity_item)

        if UffizziCore::RepoService.credential(repo).present? && activity_item.docker?
          UffizziCore::ActivityItem::Docker::UpdateDigestJob.perform_async(activity_item.id)
        end
        UffizziCore::Deployment::ManageDeployActivityItemJob.perform_in(5.seconds, activity_item.id)
      end
    end

    def create_default_activity_item_event(activity_item)
      activity_item.events.create(state: UffizziCore::Event.state.deploying) if activity_item.docker?
    end

    def update_controller_container_names(deployment)
      deployment.active_containers.each do |container|
        next if container.controller_name.present?

        controller_name = generate_controller_container_name(container)
        container.update!(controller_name: controller_name)
      end
    end

    def generate_controller_container_name(container)
      Digest::SHA256.hexdigest("#{container.id}:#{container.image}")[0, 10]
    end

    def add_default_deployment_variables!(containers)
      containers.each do |container|
        envs = []
        if container.port.present? && !UffizziCore::ContainerService.defines_env?(container, 'PORT')
          envs.push('name' => 'PORT', 'value' => container.target_port.to_s)
        end

        container.variables = [] if container.variables.nil?

        container.variables.push(*envs)
      end
    end

    def format_subdomain(full_subdomain_name)
      # Replace _ to - because RFC 1123 subdomain must consist of lower case alphanumeric characters,
      # '-' or '.', and must start and end with an alphanumeric character
      rfc_subdomain = full_subdomain_name.gsub('_', '-')
      subdomain_length_limit = Settings.deployment.subdomain.length_limit
      return rfc_subdomain if rfc_subdomain.length <= subdomain_length_limit

      rfc_subdomain.slice(0, subdomain_length_limit)
    end
  end
end
