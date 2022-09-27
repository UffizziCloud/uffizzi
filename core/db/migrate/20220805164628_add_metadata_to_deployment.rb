# frozen_string_literal: true

class AddMetadataToDeployment < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_deployments, :metadata, :jsonb, default: {})
  end
end
