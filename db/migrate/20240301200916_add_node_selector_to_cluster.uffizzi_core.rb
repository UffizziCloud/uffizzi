# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20240301200235)
class AddNodeSelectorToCluster < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :node_selector, :string)
  end
end
