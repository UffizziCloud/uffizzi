# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::ActivityItemSerializer < UffizziCore::BaseSerializer
  type :activity_item

  attributes :id, :namespace, :name, :tag, :type, :branch, :commit, :commit_message, :state, :created_at,
             :updated_at, :build_id, :data, :container_id, :digest

  def type
    return :github if object.type == ActivityItem::Github.name
    return :docker if object.type == ActivityItem::Docker.name
    return :memory_limit if object.type == ActivityItem::MemoryLimit.name

    nil
  end

  def commit
    object.commit.to_s.slice(0..6)
  end

  def state
    object.events.order_by_id.last&.state
  end
end
