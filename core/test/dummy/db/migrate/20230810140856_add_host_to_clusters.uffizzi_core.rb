# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20230711101901)

class AddHostToClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :host, :string)
  end
end
