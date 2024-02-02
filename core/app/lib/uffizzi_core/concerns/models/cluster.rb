# frozen_string_literal: true

module UffizziCore::Concerns::Models::Cluster
  extend ActiveSupport::Concern
  include UffizziCore::ClusterRepo

  NAMESPACE_PREFIX = 'c'

  # rubocop:disable Metrics/BlockLength
  included do
    include AASM
    extend Enumerize

    self.table_name = UffizziCore.table_names[:clusters]

    belongs_to :project, class_name: UffizziCore::Project.name
    belongs_to :deployed_by, class_name: UffizziCore::User.name, foreign_key: :deployed_by_id, optional: true
    belongs_to :kubernetes_distribution, optional: true

    validates_uniqueness_of :name, conditions: -> { enabled }, scope: :project_id
    validates :name, presence: true, format: { with: /\A[a-zA-Z0-9-]*\z/ }

    enumerize :creation_source, in: UffizziCore.cluster_creation_sources, scope: true, predicates: true
    attribute :creation_source, :string, default: :manual

    enumerize :kind, in: [:basic, :dev], scope: true, predicates: true
    attribute :kind, :string, default: :basic

    validates :creation_source, presence: true

    aasm(:state) do
      state :deploying_namespace, initial: true
      state :failed_deploy_namespace
      state :deploying
      state :deployed
      state :scaling_down
      state :scaled_down
      state :scaling_up
      state :failed_scale_up
      state :failed
      state :disabled

      event :start_deploying do
        transitions from: [:deploying_namespace], to: :deploying
      end

      event :fail_deploy_namespace do
        transitions from: [:deploying_namespace], to: :failed_deploy_namespace
      end

      event :finish_deploy do
        transitions from: [:deploying], to: :deployed
      end

      event :start_scaling_down do
        transitions from: [:deployed], to: :scaling_down
      end

      event :scale_down do
        transitions from: [:scaling_down], to: :scaled_down
      end

      event :start_scaling_up do
        transitions from: [:scaled_down, :failed_scale_up], to: :scaling_up
      end

      event :scale_up do
        transitions from: [:scaling_up], to: :deployed
      end

      event :fail_scale_up do
        transitions from: [:scaling_up], to: :failed_scale_up
      end

      event :fail do
        transitions from: [:deploying], to: :failed
      end

      event :disable, after: :after_disable do
        transitions from: [
          :deploying_namespace,
          :failed_deploy_namespace,
          :deploying,
          :deployed,
          :scaling_down,
          :scaling_up,
          :scaled_down,
          :failed,
        ], to: :disabled
      end
    end

    def after_disable
      UffizziCore::Cluster::DeleteJob.perform_async(id)
    end

    def namespace
      [NAMESPACE_PREFIX, id].join
    end
  end
  # rubocop:enable Metrics/BlockLength
end
