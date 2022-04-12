# frozen_string_literal: true

# @model
#
# @property id [integer]
# @property namespace [string]
# @property name(required) [string]
# @property tag [string]
# @property branch [string]
# @property type [string]
# @property container_id [string]
# @property commit [string]
# @property commit_message [string]
# @property build_id [integer]
# @property created_at [date]
# @property updated_at [date]
# @property data [object]
# @property digest [string]
# @property meta [object]

class UffizziCore::ActivityItem < UffizziCore::ApplicationRecord
  include UffizziCore::ActivityItemRepo

  self.table_name = Rails.application.config.uffizzi_core[:table_names][:activity_items]

  belongs_to :deployment
  belongs_to :container
  belongs_to :build, optional: true

  has_many :events, dependent: :destroy

  scope :docker, -> {
    where(type: UffizziCore::ActivityItem::Docker.name)
  }

  scope :github, -> {
    where(type: UffizziCore::ActivityItem::Github.name)
  }

  def docker?
    type == UffizziCore::ActivityItem::Docker.name
  end

  def image
    [namespace, name].compact.join('/')
  end

  def full_image
    return "#{image}:#{tag}" if docker?

    ''
  end
end
