class CreateContainerHostVolumeFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :container_host_volume_files do |t|
      t.string :source_path
      t.references :container, null: false, foreign_key: true
      t.references :host_volume_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
