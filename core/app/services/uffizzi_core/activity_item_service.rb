# frozen_string_literal: true

class UffizziCore::ActivityItemService
  COMPLETED_STATES = ['deployed', 'failed', 'cancelled'].freeze

  class << self
    include UffizziCore::DependencyInjectionConcern

    def create_docker_item!(repo, container)
      activity_item_attributes = {
        namespace: repo.namespace,
        name: repo.name,
        container: container,
        deployment_id: container.deployment_id,
        type: UffizziCore::ActivityItem::Docker.name,
        tag: container.tag,
      }

      create_item!(activity_item_attributes)
    end

    def fail_deployment!(activity_item)
      deployment = activity_item.container.deployment
      last_event = activity_item.events.order_by_id.last

      activity_item.events.create(state: UffizziCore::Event.state.failed) unless last_event&.failed?

      UffizziCore::DeploymentService.fail!(deployment)
    end

    def update_docker_digest!(activity_item)
      container = activity_item.container
      repo = container.repo
      credential = UffizziCore::RepoService.credential(repo)
      container_registry_service = UffizziCore::ContainerRegistryService.init_by_subclass(repo.type)
      digest = container_registry_service.digest(credential, activity_item.image, activity_item.tag)

      activity_item.update!(digest: digest)

      activity_item
    end

    def manage_deploy_activity_item(activity_item)
      container = activity_item.container
      deployment = container.deployment
      service = UffizziCore::ManageActivityItemsService.new(deployment)
      container_status_item = service.container_status_item(container)
      return if container_status_item.nil?

      status = container_status_item[:status]
      last_event = activity_item.events.order_by_id.last
      activity_item.events.create(state: status) if last_event&.state != status

      return handle_failed_status(activity_item, deployment) if failed?(status)

      if deployed?(status) && UffizziCore::ContainerService.ingress_container?(container)
        return deployment.update(last_deploy_at: last_event.created_at)
      end

      return unless [UffizziCore::Event.state.building, UffizziCore::Event.state.deploying].include?(status)

      UffizziCore::Deployment::ManageDeployActivityItemJob.perform_in(5.seconds, activity_item.id)
    end

    private

    def handle_failed_status(activity_item, deployment)
      UffizziCore::ActivityItemService.fail_deployment!(activity_item)
      notification_module.notify_about_failed_deployment(deployment) if notification_module.present?
    end

    def create_item!(activity_item_attributes)
      activity_item = UffizziCore::ActivityItem.find_by(activity_item_attributes)
      return activity_item unless completed?(activity_item)

      UffizziCore::ActivityItem.create!(activity_item_attributes)
    end

    def completed?(activity_item)
      return true if activity_item.nil?

      last_event = activity_item.events.order_by_id.last
      COMPLETED_STATES.include?(last_event.state)
    end

    def failed?(status)
      status == UffizziCore::Event.state.failed
    end

    def deployed?(status)
      status == UffizziCore::Event.state.deployed
    end
  end
end
