# frozen_string_literal: true

module UffizziCore::Concerns::Models::KubernetesDistribution
  extend ActiveSupport::Concern

  included do
    self.table_name = UffizziCore.table_names[:kubernetes_distributions]

    has_many :clusters

    def self.default
      find_by(default: true)
    end
  end
end
