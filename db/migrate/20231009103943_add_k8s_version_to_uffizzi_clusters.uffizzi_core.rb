# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20231009102139)

class AddK8sVersionToUffizziClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :k8s_version, :string)
  end
end
