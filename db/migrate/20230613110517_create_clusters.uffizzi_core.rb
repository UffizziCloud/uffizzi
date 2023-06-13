# frozen_string_literal: true

# This migration comes from uffizzi_core (originally 20230613101901)
class CreateClusters < ActiveRecord::Migration[6.1]
  def change
    create_table('uffizzi_core_clusters', force: :cascade) do |t|
      t.references :project, null: false,
                             foreign_key: true,
                             index: { name: :index_cluster_on_project_id },
                             foreign_key: { to_table: :uffizzi_core_projects }
      t.bigint 'deployed_by_id', foreign_key: true
      t.string 'state'
      t.string 'name'

      t.timestamps
    end
  end
end
