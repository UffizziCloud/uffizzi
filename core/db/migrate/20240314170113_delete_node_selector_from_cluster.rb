# frozen_string_literal: true

class DeleteNodeSelectorFromCluster < ActiveRecord::Migration[6.1]
  def change
    remove_column(:uffizzi_core_clusters, :node_selector, :string)
  end
end
