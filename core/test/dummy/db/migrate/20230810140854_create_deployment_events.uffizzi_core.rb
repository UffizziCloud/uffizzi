# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20230531135739)

class CreateDeploymentEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :uffizzi_core_deployment_events do |t|
      t.string :deployment_state
      t.string :message
      t.timestamps
      t.references :deployment, null: false,
                                index: { name: :uf_core_dep_events_on_dep },
                                foreign_key: { to_table: :uffizzi_core_deployments }
    end
  end
end
