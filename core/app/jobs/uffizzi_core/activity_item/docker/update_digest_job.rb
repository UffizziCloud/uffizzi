# frozen_string_literal: true

class UffizziCore::ActivityItem::Docker::UpdateDigestJob < UffizziCore::ApplicationJob
  sidekiq_options queue: :deployments, retry: 5

  def perform(id)
    activity_item = UffizziCore::ActivityItem.find(id)

    UffizziCore::ActivityItemService.update_docker_digest!(activity_item)
  end
end
