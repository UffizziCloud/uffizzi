# frozen_string_literal: true

class CreateContainerHostVolumeFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :uffizzi_core_container_host_volume_files do |t|
      t.string :source_path
      t.timestamps
      t.references :container, null: false,
                               foreign_key: true,
                               index: { name: :uf_core_cont_h_v_on_cont },
                               foreign_key: { to_table: :uffizzi_core_containers }
      t.references :host_volume_file, null: false,
                                      foreign_key: true,
                                      index: { name: :uf_core_cont_h_v_on_h_v_file },
                                      foreign_key: { to_table: :uffizzi_core_host_volume_files }
    end
  end
end
