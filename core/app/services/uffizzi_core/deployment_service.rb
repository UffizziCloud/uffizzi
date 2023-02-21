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
    include UffizziCore::DependencyInjectionConcern

    def create_from_compose(compose_file, project, user, params)
      deployment_attributes = ActionController::Parameters.new(compose_file.template.payload)
      deployment_form = UffizziCore::Api::Cli::V1::Deployment::CreateForm.new(deployment_attributes)
      deployment_form.assign_dependences!(project, user)
      deployment_form.compose_file = compose_file
      deployment_form.creation_source = params[:creation_source] || UffizziCore::Deployment.creation_source.compose_file_manual
      deployment_form.metadata = params[:metadata] || {}

      run_deployment_creation_tasks(deployment_form) if deployment_form.save

      deployment_form
    end

    def update_from_compose(compose_file, project, user, deployment, metadata)
      deployment_attributes = ActionController::Parameters.new(compose_file.template.payload)

      deployment_form = UffizziCore::Api::Cli::V1::Deployment::UpdateForm.new(deployment_attributes)
      deployment_form.assign_dependences!(project, user)
      deployment_form.compose_file = compose_file
      deployment_form.metadata = metadata || {}

      ActiveRecord::Base.transaction do
        deployment.containers.destroy_all
        deployment.compose_file.destroy! if deployment.compose_file&.kind&.temporary?
        deployment.activate unless deployment.active?
        params = {
          containers: deployment_form.containers,
          compose_file_id: compose_file.id,
          metadata: deployment_form.metadata,
        }
        deployment.update!(params)
      end

      deployment
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
        containers_with_variables = add_default_deployment_variables!(containers, deployment)

        UffizziCore::ControllerService.deploy_containers(deployment, containers_with_variables)
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

      new_deployment_subdomain = DomainService.build_subdomain(deployment)

      if new_deployment_subdomain != old_deployment_subdomain
        deployment.update(subdomain: new_deployment_subdomain)
      end

      UffizziCore::Deployment::DeployContainersJob.perform_async(deployment.id)
    end

    def pull_request_payload_present?(deployment)
      deployment.continuous_preview_payload.present? && deployment.continuous_preview_payload['pull_request'].present?
    end

    def failed?(deployment)
      deployment_status = deployment_process_status(deployment)

      deployment_status == DEPLOYMENT_PROCESS_STATUSES[:failed]
    end

    private

    def run_deployment_creation_tasks(deployment)
      UffizziCore::Deployment::DomainService.update_subdomain!(deployment)

      UffizziCore::Deployment::CreateJob.perform_async(deployment.id)
    end

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
      current_time = Time.now

      deployment.active_containers.each do |container|
        container.update!(apply_at: current_time)
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

    def add_default_deployment_variables!(containers, deployment)
      containers.each do |container|
        envs = []
        if container.port.present? && !UffizziCore::ContainerService.defines_env?(container, 'PORT')
          envs.push('name' => 'PORT', 'value' => container.target_port.to_s)
        end

        envs.push('name' => 'UFFIZZI_URL', 'value' => "https://#{deployment.preview_url}")
        envs.push('name' => 'UFFIZZI_DOMAIN', 'value' => deployment.preview_url)

        preview_url = "https://#{domain_module.build_preview_url(deployment)}" if domain_module.present?
        envs.push('name' => 'UFFIZZI_PREDICTABLE_URL', 'value' => preview_url || '')

        container.variables = [] if container.variables.nil?

        container.variables.push(*envs)
      end
    end
  end
end
