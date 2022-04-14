# frozen_string_literal: true

class UffizziCore::ActivityItemService
  COMPLETED_STATES = ['deployed', 'failed', 'cancelled'].freeze

  class << self
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

    def disable_deployment!(activity_item)
      deployment = activity_item.container.deployment

      activity_item.events.create(state: UffizziCore::Event.state.failed)

      UffizziCore::DeploymentService.disable!(deployment)
    end

    def update_docker_digest!(activity_item)
      container = activity_item.container
      repo = container.repo
      credential = UffizziCore::RepoService.credential(repo)

      digest = case repo.type
               when UffizziCore::Repo::DockerHub.name
                 UffizziCore::DockerHubService.digest(credential, activity_item.image, activity_item.tag)
               when UffizziCore::Repo::Azure.name
                 UffizziCore::AzureService.digest(credential, activity_item.image, activity_item.tag)
               when UffizziCore::Repo::Google.name
                 UffizziCore::GoogleService.digest(credential, activity_item.image, activity_item.tag)
               when UffizziCore::Repo::Amazon.name
                 UffizziCore::AmazonService.digest(credential, activity_item.image, activity_item.tag)
      end

      activity_item.update!(digest: digest)

      activity_item
    end

    def manage_deploy_activity_item(activity_item)
      container = activity_item.container
      deployment = container.deployment
      service = UffizziCore::ManageActivityItemsService.new(deployment)
      container_status_item = service.container_status_item(container)
      status = container_status_item[:status]
      last_event = activity_item.events.order_by_id.last

      activity_item.events.create(state: status) if last_event&.state != status

      return unless [UffizziCore::Event.state.building, UffizziCore::Event.state.deploying].include?(status)

      UffizziCore::Deployment::ManageDeployActivityItemJob.perform_in(5.seconds, activity_item.id)
    end

    private

    def create_item!(activity_item_attributes)
      activity_item = UffizziCore::ActivityItem.find_by(activity_item_attributes)
      return activity_item unless completed?(activity_item)

      UffizziCore::ActivityItem.create!(activity_item_attributes)
    end

    def completed?(activity_item)
      return true if activity_item.nil?

      last_event = activity_item.events.last
      COMPLETED_STATES.include?(last_event.state)
    end
  end
end
