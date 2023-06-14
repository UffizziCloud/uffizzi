# frozen_string_literal: true

module UffizziCore::Concerns::Models::Cluster
  extend ActiveSupport::Concern
  include UffizziCore::ClusterRepo

  included do
    include AASM

    self.table_name = UffizziCore.table_names[:clusters]

    belongs_to :project, class_name: UffizziCore::Project.name
    belongs_to :deployed_by, class_name: UffizziCore::User.name, foreign_key: :deployed_by_id, optional: true
    validates :name, uniqueness: true, if: -> { deployed? }
    validates :name, presence: true, format: { with: /([A-Za-z0-9\-_]+)/ }

    aasm(:state) do
      state :deploying_namespace, initial: true
      state :failed_deploy_namespace
      state :deploying
      state :deployed
      state :failed
      state :disabled

      event :start_deploying do
        transitions from: [:deploying_namespace], to: :deploying
      end

      event :fail_deploy_namespace do
        transitions from: [:deploying_namespace], to: :failed_deploy_namespace
      end

      event :finish_deploy do
        transitions from: [:deploying], to: :deploying_namespace
      end

      event :fail do
        transitions from: [:deploying], to: :failed
      end

      event :disable do
        transitions from: [:deploying, :deployed, :failed], to: :disabled
      end
    end

    def namespace
      return name if name.present?

      "cluster-#{id}"
    end
  end
end
