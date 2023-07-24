# frozen_string_literal: true

class AddHostToClusters < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_clusters, :host, :string)
  end
end
