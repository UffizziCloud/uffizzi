# frozen_string_literal: true

module UffizziCore::Concerns::Models::ActivityItem
  extend ActiveSupport::Concern

  included do
    include UffizziCore::ActivityItemRepo

    self.table_name = UffizziCore.table_names[:activity_items]

    belongs_to :deployment
    belongs_to :container
    belongs_to :build, optional: true

    has_many :events, dependent: :destroy

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
end
