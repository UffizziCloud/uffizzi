# frozen_string_literal: true

class AddNodeSelectorToCluster < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :node_selector, :string)
  end
end
