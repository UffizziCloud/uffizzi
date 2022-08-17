# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20220805164628)

class AddMetadataToDeployment < ActiveRecord::Migration[6.1]
  def change
    add_column(:uffizzi_core_deployments, :metadata, :jsonb, default: {})
  end
end
