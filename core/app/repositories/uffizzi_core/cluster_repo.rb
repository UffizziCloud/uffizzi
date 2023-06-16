# frozen_string_literal: true

module UffizziCore::ClusterRepo
  extend ActiveSupport::Concern

  included do
    scope :deployed, -> { where(state: UffizziCore::Cluster::STATE_DEPLOYED) }
    scope :enabled, -> { where.not(state: [UffizziCore::Cluster::STATE_FAILED_DEPLOY_NAMESPACE, UffizziCore::Cluster::STATE_DISABLED]) }
  end
end
