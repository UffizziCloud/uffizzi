# frozen_string_literal: true

module UffizziCore::ClusterRepo
  extend ActiveSupport::Concern

  included do
    scope :deployed, -> { where(state: UffizziCore::Cluster::STATE_DEPLOYED) }
  end
end
