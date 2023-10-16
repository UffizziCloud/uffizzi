# frozen_string_literal: true

class AddKubernetesDistributionIdToUffizziCoreClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :kubernetes_distribution_id, :integer, foreign_key: true)
  end
end
