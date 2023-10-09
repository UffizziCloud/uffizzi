# frozen_string_literal: true

class AddK8sVersionToUffizziClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :k8s_version, :string)
  end
end
