# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20231009182412)
class AddKubernetesDistributionIdToUffizziCoreClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :kubernetes_distribution_id, :integer, foreign_key: true)
  end
end
