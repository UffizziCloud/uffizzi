# frozen_string_literal: true

class AddKindToCluster < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :kind, :string)
  end
end
