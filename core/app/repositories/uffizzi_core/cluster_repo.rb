# frozen_string_literal: true

module UffizziCore::ClusterRepo
  extend ActiveSupport::Concern

  included do
    scope :deployed, -> { where(state: UffizziCore::Cluster::STATE_DEPLOYED) }
    scope :enabled, -> { where.not(state: UffizziCore::Cluster::STATE_DISABLED) }
    scope :deployed_by_user, ->(user) { where(deployed_by: user) }
    scope :by_projects, ->(projects) { where(project_id: projects.select(:id)) }
  end
end
