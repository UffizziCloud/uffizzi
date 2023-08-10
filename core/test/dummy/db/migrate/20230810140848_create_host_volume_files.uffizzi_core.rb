# frozen_string_literal: true
# This migration comes from uffizzi_core (originally 20220901110752)

class CreateHostVolumeFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :uffizzi_core_host_volume_files do |t|
      t.string :source
      t.string :path
      t.boolean :is_file
      t.binary :payload
      t.bigint :added_by_id
      t.timestamps

      t.references :project, null: false,
                             foreign_key: true,
                             index: { name: :index_host_volume_file_on_project_id },
                             foreign_key: { to_table: :uffizzi_core_projects }
      t.references :compose_file, null: false,
                                  foreign_key: true,
                                  index: { name: :index_host_volume_file_on_compose_file_id },
                                  foreign_key: { to_table: :uffizzi_core_compose_files }
    end
  end
end
