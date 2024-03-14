# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20240314170113)
class DeleteNodeSelectorFromCluster < ActiveRecord::Migration[6.1]
  def change
    remove_column(:uffizzi_core_clusters, :node_selector, :string)
  end
end
