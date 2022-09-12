class CreateHostVolumeFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :host_volume_files do |t|
      t.string :source
      t.string :path
      t.boolean :is_file
      t.binary :payload
      t.bigint :added_by_id
      t.references :project, null: false, foreign_key: true
      t.references :compose_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
